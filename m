Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sperry-03.control.lth.se ([130.235.83.190]:43031 "EHLO
	sperry-03.control.lth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbbJWIU6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2015 04:20:58 -0400
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
From: Anders Blomdell <anders.blomdell@control.lth.se>
Subject: NULL pointer dereference in nfs_delegation_find_inode
Message-ID: <5629E933.8030807@control.lth.se>
Date: Fri, 23 Oct 2015 10:00:51 +0200
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040809060102060109030207"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040809060102060109030207
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

We occasionally (about once every 2-4 weeks on 1 of a 100 machenes) get 

  BUG: unable to handle kernel NULL pointer dereference at 0000000000000548
  IP: [<ffffffffa0651744>] nfs_delegation_find_inode+0x64/0x150 [nfsv4]

the attached bug is from 4.1.8-100.fc21, but I have seen it on 4.1.5-100.fc21 as
well. Right now I have a realtime modified (xenomai.org) 3.8.13 system that exhibits
the problem more frequently, and that leads me to belive that the problem is
a data race problem, and by instrumenting fs/nfs/delegation.c (3.8.13) to:


  static struct inode *
  nfs_delegation_find_inode_server(struct nfs_server *server,
				 const struct nfs_fh *fhandle)
  {
	  struct nfs_delegation *delegation;
	  struct inode *res = NULL;

 	  printk(KERN_ERR "server = %p\n", server);
	  list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
		  printk(KERN_ERR "delegation = %p\n", delegation);
		  printk(KERN_ERR "delegation->lock = %p\n", delegation->lock);
		  spin_lock(&delegation->lock);
		  printk(KERN_ERR "delegation->inode = %p\n", delegation->inode);
		  if (delegation->inode != NULL) {
			  printk(KERN_ERR "NFS_I(delegation->inode) = %p", NFS_I(delegation->inode));
			  printk(KERN_ERR "NFS_I(delegation->inode)->fh = %p", NFS_I(delegation->inode)->fh);
		  }
		  if (delegation->inode != NULL &&
		      nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
			  res = igrab(delegation->inode);
		  }
		  spin_unlock(&delegation->lock);
		  if (res != NULL)
			  break;
	  }
	  return res;
  }

the system dies with (delegation.c compiled with -O0):

  server = ffff8803dee58458
  delegation =           (null)
  BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
  IP: [<ffffffffa08924ae>] nfs_delegation_find_inode_server+0x80/0x1e0 [nfsv4]

Anybody thet can give me a hint how to write a program that gives rise to multiple 
delegations to further investigate this issue?

Regards

Anders Blomdell

-- 
Anders Blomdell                  Email: anders.blomdell@control.lth.se
Department of Automatic Control
Lund University                  Phone:    +46 46 222 4625
P.O. Box 118                     Fax:      +46 46 138118
SE-221 00 Lund, Sweden


--------------040809060102060109030207
Content-Type: text/plain; charset=UTF-8;
 name="nfs_delegation_find_inode.bug"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs_delegation_find_inode.bug"

WzQzNjQyNy4wNjkzNDldIEJVRzogdW5hYmxlIHRvIGhhbmRsZSBrZXJuZWwgTlVMTCBwb2lu
dGVyIGRlcmVmZXJlbmNlIGF0IDAwMDAwMDAwMDAwMDA1NDgKWzQzNjQyNy4wNzE3ODhdIElQ
OiBbPGZmZmZmZmZmYTA2NTE3NDQ+XSBuZnNfZGVsZWdhdGlvbl9maW5kX2lub2RlKzB4NjQv
MHgxNTAgW25mc3Y0XQpbNDM2NDI3LjA3NDM0Ml0gUEdEIDAgCls0MzY0MjcuMDc2ODM0XSBP
b3BzOiAwMDAwIFsjMV0gU01QIApbNDM2NDI3LjA3OTMxM10gTW9kdWxlcyBsaW5rZWQgaW46
IGJ0cmZzIHhvciByYWlkNl9wcSB1ZnMgaGZzcGx1cyBoZnMgbWluaXggdmZhdCBtc2RvcyBm
YXQgamZzIHhmcyBsaWJjcmMzMmMgYm5lcCBibHVldG9vdGggcnBjc2VjX2dzc19rcmI1IG5m
c3Y0IGRuc19yZXNvbHZlciBuZnMgZnNjYWNoZSBmdXNlIHh0X0NIRUNLU1VNIGlwdF9NQVNR
VUVSQURFIG5mX25hdF9tYXNxdWVyYWRlX2lwdjQgdHVuIGlwNnRfcnBmaWx0ZXIgaXA2dF9S
RUpFQ1QgbmZfcmVqZWN0X2lwdjYgeHRfY29ubnRyYWNrIGVidGFibGVfbmF0IGVidGFibGVf
YnJvdXRlIGJyaWRnZSBzdHAgbGxjIGVidGFibGVfZmlsdGVyIGVidGFibGVzIGlwNnRhYmxl
X25hdCBuZl9jb25udHJhY2tfaXB2NiBuZl9kZWZyYWdfaXB2NiBuZl9uYXRfaXB2NiBpcDZ0
YWJsZV9tYW5nbGUgaXA2dGFibGVfc2VjdXJpdHkgaXA2dGFibGVfcmF3IGlwNnRhYmxlX2Zp
bHRlciBpcDZfdGFibGVzIGlwdGFibGVfbmF0IG5mX2Nvbm50cmFja19pcHY0IG5mX2RlZnJh
Z19pcHY0IG5mX25hdF9pcHY0IG5mX25hdCBuZl9jb25udHJhY2sgaXB0YWJsZV9tYW5nbGUg
aXB0YWJsZV9zZWN1cml0eSBpcHRhYmxlX3JhdyBkdW1teSBzbmRfaGRhX2NvZGVjX3JlYWx0
ZWsgc25kX2hkYV9jb2RlY19oZG1pIHNuZF9oZGFfY29kZWNfZ2VuZXJpYyBzbmRfaGRhX2lu
dGVsIHNuZF9oZGFfY29udHJvbGxlciBzbmRfaGRhX2NvZGVjIGpveWRldiBzbmRfaGRhX2Nv
cmUgaW50ZWxfcmFwbCBpb3NmX21iaSBzbmRfaHdkZXAgc25kX3NlcSBzbmRfc2VxX2Rldmlj
ZSBzbmRfcGNtIHg4Nl9wa2dfdGVtcF90aGVybWFsIGNvcmV0ZW1wIGt2bSBjcmN0MTBkaWZf
cGNsbXVsIHNuZF90aW1lciBjcmMzMl9wY2xtdWwgc25kIGlUQ09fd2R0IGVlZXBjX3dtaSBp
VENPX3ZlbmRvcl9zdXBwb3J0IGFzdXNfd21pIHNwYXJzZV9rZXltYXAgcmZraWxsIGNyYzMy
Y19pbnRlbCBteG1fd21pIGdoYXNoX2NsbXVsbmlfaW50ZWwgc291bmRjb3JlIHNocGNocCBs
cGNfaWNoIG1mZF9jb3JlIG1laV9tZSBtZWkgaTJjX2k4MDEgdHBtX2luZmluZW9uIHRwbV90
aXMgdHBtIHdtaSBhY3BpX3BhZCBuZnNkIGF1dGhfcnBjZ3NzIG5mc19hY2wgbG9ja2QgZ3Jh
Y2UgYmluZm10X21pc2Mgc3VucnBjIGk5MTUgaTJjX2FsZ29fYml0IGRybV9rbXNfaGVscGVy
IGRybSByODE2OSBzZXJpb19yYXcgbWlpIHZpZGVvCls0MzY0MjcuMDk1MDcxXSBDUFU6IDAg
UElEOiAyNTc5IENvbW06IG5mc3Y0LjAtc3ZjIE5vdCB0YWludGVkIDQuMS44LTEwMC5mYzIx
Lng4Nl82NCAjMQpbNDM2NDI3LjA5ODcyOV0gSGFyZHdhcmUgbmFtZTogQVNVUyBBbGwgU2Vy
aWVzL1o5Ny1QLCBCSU9TIDI4MDEgMDQvMDgvMjAxNQpbNDM2NDI3LjEwMjQwMF0gdGFzazog
ZmZmZjg4MDdlYzY0NThlMCB0aTogZmZmZjg4MDdkZGI0MDAwMCB0YXNrLnRpOiBmZmZmODgw
N2RkYjQwMDAwCls0MzY0MjcuMTA2MTAyXSBSSVA6IDAwMTA6WzxmZmZmZmZmZmEwNjUxNzQ0
Pl0gIFs8ZmZmZmZmZmZhMDY1MTc0ND5dIG5mc19kZWxlZ2F0aW9uX2ZpbmRfaW5vZGUrMHg2
NC8weDE1MCBbbmZzdjRdCls0MzY0MjcuMTA5ODkxXSBSU1A6IDAwMTg6ZmZmZjg4MDdkZGI0
M2MzOCAgRUZMQUdTOiAwMDAxMDI4MgpbNDM2NDI3LjExMzY1OV0gUkFYOiAwMDAwMDAwMDAw
MDAwMDAwIFJCWDogZmZmZjg4MDdlNTU2NzgwMCBSQ1g6IGZmZmZmZmZmZmZmZmZmZjgKWzQz
NjQyNy4xMTc0NjJdIFJEWDogZmZmZjg4MDdkZGI0M2QyMCBSU0k6IGZmZmY4ODA3ZTU1Njc4
MGEgUkRJOiBmZmZmODgwN2YyNThjMDAwCls0MzY0MjcuMTIxMjU1XSBSQlA6IGZmZmY4ODA3
ZGRiNDNjOTggUjA4OiAwMDAwMDAwMDAwMDAwMDAwIFIwOTogMDAwMDAwMDAwMDAwMDAwMApb
NDM2NDI3LjEyNTAzOF0gUjEwOiAwMDAwMDAwMDAwMDAwMDAxIFIxMTogZmZmZmVhMDAxYzE4
ZjEwMCBSMTI6IDAwMDAwMDAwMDAwMDAwMDEKWzQzNjQyNy4xMjg4MThdIFIxMzogMDAwMDAw
MDAwMDAwMDAwNCBSMTQ6IDAwMDAwMDAwMTEyNzAwMDAgUjE1OiAwMDAwMDAwMDAwMDAwMDAw
Cls0MzY0MjcuMTMyNjA0XSBGUzogIDAwMDAwMDAwMDAwMDAwMDAoMDAwMCkgR1M6ZmZmZjg4
MDgxZmEwMDAwMCgwMDAwKSBrbmxHUzowMDAwMDAwMDAwMDAwMDAwCls0MzY0MjcuMTM2NDE1
XSBDUzogIDAwMTAgRFM6IDAwMDAgRVM6IDAwMDAgQ1IwOiAwMDAwMDAwMDgwMDUwMDMzCls0
MzY0MjcuMTQwMjIxXSBDUjI6IDAwMDAwMDAwMDAwMDA1NDggQ1IzOiAwMDAwMDAwMDAxYzBi
MDAwIENSNDogMDAwMDAwMDAwMDE0MDZmMApbNDM2NDI3LjE0NDA1NV0gU3RhY2s6Cls0MzY0
MjcuMTQ3ODczXSAgZmZmZjg4MDdmMjU4YzBjOCBmZmZmZmZmZmZmZmZmZmY4IGZmZmY4ODA3
ZTU1Njc4MGEgZmZmZjg4MDdlNTU2NzgwOApbNDM2NDI3LjE1MTc4Ml0gIDAwMDAwMDAwMDAw
MDAwMDAgMDAwMDAwMDBkOTk3ZWU1MSBmZmZmODgwN2U1NTY3ODAwIGZmZmY4ODA3ZTU1Njc4
MDAKWzQzNjQyNy4xNTU3MDBdICAwMDAwMDAwMDAwMDAwMDAxIDAwMDAwMDAwMDAwMDAwMDQg
MDAwMDAwMDAxMTI3MDAwMCAwMDAwMDAwMDAwMDAwMDAwCls0MzY0MjcuMTU5NjMwXSBDYWxs
IFRyYWNlOgpbNDM2NDI3LjE2MzU1MV0gIFs8ZmZmZmZmZmZhMDY1NTE1MD5dIG5mczRfY2Fs
bGJhY2tfcmVjYWxsKzB4NDAvMHgxOTAgW25mc3Y0XQpbNDM2NDI3LjE2NzUyMl0gIFs8ZmZm
ZmZmZmZhMDY1NDc0Mj5dID8gZGVjb2RlX3JlY2FsbF9hcmdzKzB4NzIvMHhkMCBbbmZzdjRd
Cls0MzY0MjcuMTcxNDg5XSAgWzxmZmZmZmZmZmEwNjU0MTJmPl0gbmZzNF9jYWxsYmFja19j
b21wb3VuZCsweDQzZi8weDc1MCBbbmZzdjRdCls0MzY0MjcuMTc1NDkzXSAgWzxmZmZmZmZm
ZmEwMWViZmU0Pl0gc3ZjX3Byb2Nlc3NfY29tbW9uKzB4NjA0LzB4NmEwIFtzdW5ycGNdCls0
MzY0MjcuMTc5NTAwXSAgWzxmZmZmZmZmZmEwNjUyYzMwPl0gPyBuZnNfY2FsbGJhY2tfYXV0
aGVudGljYXRlKzB4NTAvMHg1MCBbbmZzdjRdCls0MzY0MjcuMTgzNTE0XSAgWzxmZmZmZmZm
ZmEwMWVjMTkzPl0gc3ZjX3Byb2Nlc3MrMHgxMTMvMHgxYjAgW3N1bnJwY10KWzQzNjQyNy4x
ODc0OTldICBbPGZmZmZmZmZmYTA2NTJjMzA+XSA/IG5mc19jYWxsYmFja19hdXRoZW50aWNh
dGUrMHg1MC8weDUwIFtuZnN2NF0KWzQzNjQyNy4xOTE0OTJdICBbPGZmZmZmZmZmYTA2NTJj
N2Q+XSBuZnM0X2NhbGxiYWNrX3N2YysweDRkLzB4NjAgW25mc3Y0XQpbNDM2NDI3LjE5NTQ1
OV0gIFs8ZmZmZmZmZmY4MTBjMDZjOD5dIGt0aHJlYWQrMHhkOC8weGYwCls0MzY0MjcuMTk5
NDA4XSAgWzxmZmZmZmZmZjgxMGMwNWYwPl0gPyBrdGhyZWFkX2NyZWF0ZV9vbl9ub2RlKzB4
MWIwLzB4MWIwCls0MzY0MjcuMjAzMzYxXSAgWzxmZmZmZmZmZjgxNzk4ZDIyPl0gcmV0X2Zy
b21fZm9yaysweDQyLzB4NzAKWzQzNjQyNy4yMDcyNDZdICBbPGZmZmZmZmZmODEwYzA1ZjA+
XSA/IGt0aHJlYWRfY3JlYXRlX29uX25vZGUrMHgxYjAvMHgxYjAKWzQzNjQyNy4yMTEwNjZd
IENvZGU6IDg5IDQ1IGMwIDQ4IDhiIDQ1IGMwIDQ4IDhkIDQ4IGY4IDQ4IDg5IDRkIGE4IDQ4
IDhkIDhmIGM4IDAwIDAwIDAwIDQ4IDM5IGMxIDQ4IDg5IDRkIGEwIDBmIDg0IGM2IDAwIDAw
IDAwIDBmIDFmIDQwIDAwIDQ4IDhiIDRkIGE4IDw0OD4gOGIgODEgNTAgMDUgMDAgMDAgNDgg
OGQgOTkgNTAgMDUgMDAgMDAgNDggODkgNDUgYzAgNGMgOGIgNmQgCls0MzY0MjcuMjE1Mjk1
XSBSSVAgIFs8ZmZmZmZmZmZhMDY1MTc0ND5dIG5mc19kZWxlZ2F0aW9uX2ZpbmRfaW5vZGUr
MHg2NC8weDE1MCBbbmZzdjRdCls0MzY0MjcuMjE5MzgyXSAgUlNQIDxmZmZmODgwN2RkYjQz
YzM4PgpbNDM2NDI3LjIyMzQzOF0gQ1IyOiAwMDAwMDAwMDAwMDAwNTQ4Cls0MzY0MjcuMjUz
MjYzXSAtLS1bIGVuZCB0cmFjZSA4NjM1MGE0YmEwY2ExYmEzIF0tLS0K
--------------040809060102060109030207--
