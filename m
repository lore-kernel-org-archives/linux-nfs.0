From: Mark Hemment <markhe@veritas.com>
Subject: Re: lockd fails to purge blocked NLM_LOCKs
Date: Wed, 6 Aug 2003 12:27:59 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0308061158190.1062-300000@localhost.localdomain>
References: <16173.61548.939819.343488@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-886247951-1060169279=:1062"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay-bridge.veritas.com ([143.127.3.10] helo=mtvmime03.VERITAS.COM)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kMRu-0006wQ-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Aug 2003 04:27:22 -0700
Received: from localhost.localdomain(markhe.wat.veritas.com[10.10.185.104]) (11671 bytes) by megami
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <markhe@veritas.com>)
	id <m19kMRn-00007UC@megami>
	for <nfs@lists.sourceforge.net>; Wed, 6 Aug 2003 04:27:15 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16173.61548.939819.343488@gargle.gargle.HOWL>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--8323328-886247951-1060169279=:1062
Content-Type: text/plain; charset="us-ascii"

On Mon, 4 Aug 2003, Neil Brown wrote:

> On Friday August 1, markhe@veritas.com wrote:
> >   When stopping server-side NFS, or deleting a client (NFSCTL_DELCLIENT),
> > lockd fails to purge blocked lockd requests.
>
> Thanks Mark.  I'm at least largely convinced.
>
> My only question concerns nlmsvc_traverse_blocks.
> This uses b_host and you have (subtley) changed the meaning of b_host.

  That is the idea.
  In host.c, the nlm_hosts[] 'database' contains two types of entries;
	a) those created with an "svc_client" (h_exportent != NULL)
	b) those created without an "svc_client" (h_exportent = NULL)

  Type a) entries refer back to nfsd's client 'database'.
  Type b) entries are independent of nfsd.

  nlmsvc_traverse_blocks() is expecting ->b_host to refer to an entry in
"nlm_hosts[]" which refers back to a type a) entry.  Without the patch,
->b_host refers to a type b) entry.

  I've attached my write-up from our internal bug tracking system; it has
a bit more detailed.

  Also, I've attached a simple program for demonstrating the problem
(foo-lock).  The steps are;
	  i) Create a scratch filesystem on the Linux NFS server and
	     mount it, say at point /mnt/fs1, and export it. Created a
	     small test file;
		# cp /etc/hosts /mnt/fs1/testfile
	 ii) Mount the exported filesystem on a client, sat at point
	     /mnt/scratch
	iii) Login to a client twice.
	     On the first login, run the test program;
		# ./foo-lock /mnt/scratch/testfile
		Attempting to get lock...
		Got lock..sleeping for 60 seconds
	     On the second login, run the test program before the
	     first expires - it will
	     block for the lock;
		# ./foo-lock /mnt/scratch/testfile
		Attempting to get lock...
	 iv) Stop NFS on the server before the first test program expires.
	     For RedHat;
		# /etc/init.d/nfs stop
	  v) Now try to umount the fileystem on the server;
		# umount /mnt/fs1
	     Busy?  Even stopping lockd will not help.  The server needs
	     to be rebooted.

Thanks,
Mark

--8323328-886247951-1060169279=:1062
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="foo-lock.c"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0308061227590.1062@localhost.localdomain>
Content-Description: foo-lock.c
Content-Disposition: attachment; filename="foo-lock.c"

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8dW5pc3RkLmg+DQojaW5j
bHVkZSA8c3lzL3R5cGVzLmg+DQojaW5jbHVkZSA8c3lzL3N0YXQuaD4NCiNp
bmNsdWRlIDxmY250bC5oPg0KDQojZGVmaW5lCVNMRUVQVElNRQk2MA0KI2Rl
ZmluZSBTdHIoeCkJCSN4DQojZGVmaW5lIFhzdHIoeCkJCVN0cih4KQ0KDQp2
b2lkDQp1c2FnZSh2b2lkKQ0Kew0KCWZwcmludGYoc3RkZXJyLCAiVXNhZ2U6
IGZvby1sb2NrIHBhdGhuYW1lXG4iKTsNCglleGl0KDIpOw0KfQ0KDQppbnQN
Cm1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQ0Kew0KCXN0cnVjdCBmbG9j
awlmbG9jazsNCglpbnQJCWZkOw0KDQoJaWYgKGFyZ2MgIT0gMikgew0KCQl1
c2FnZSgpOw0KCQkvKiBOT1RSRUFDSEVEICovDQoJfQ0KDQoJZmQgPSBvcGVu
KGFyZ3ZbMV0sIE9fUkRXUik7DQoJaWYgKGZkID09IC0xKSB7DQoJCXBlcnJv
cigib3BlbiIpOw0KCQlleGl0KDEpOw0KCX0NCg0KCWZsb2NrLmxfdHlwZSA9
IEZfV1JMQ0s7DQoJZmxvY2subF93aGVuY2UgPSBTRUVLX1NFVDsNCglmbG9j
ay5sX3N0YXJ0ID0gMDsNCglmbG9jay5sX2xlbiA9IChvZmZfdCkxMDsNCg0K
CXByaW50ZigiQXR0ZW1wdGluZyB0byBnZXQgbG9jay4uLlxuIik7DQoJaWYg
KGZjbnRsKGZkLCBGX1NFVExLVywgJmZsb2NrKSA9PSAtMSkgew0KCQlwZXJy
b3IoImZjbnRsIik7DQoJCWV4aXQoMSk7DQoJfQ0KDQoJcHJpbnRmKCJHb3Qg
bG9jay4uc2xlZXBpbmcgZm9yICIgWHN0cihTTEVFUFRJTUUpICIgc2Vjb25k
c1xuIik7DQoJc2xlZXAoU0xFRVBUSU1FKTsNCg0KCXByaW50ZigiQ2xvc2lu
ZyBmaWxlXG4iKTsNCgkodm9pZCljbG9zZShmZCk7DQoJZXhpdCgwKTsNCn0N
Cg==
--8323328-886247951-1060169279=:1062
Content-Type: TEXT/plain; name="incident-127591.txt"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0308061227591.1062@localhost.localdomain>
Content-Description: incident-127591.txt
Content-Disposition: attachment; filename="incident-127591.txt"

ICBXaGVuIHRoZSBzZXJ2ZXIgY2Fubm90IGltbWVkaWF0ZWx5IGdyYW50IGEg
bG9jayByZXF1ZXN0IChOTE1fTE9DSyksDQppdCBjcmVhdGVzIGFuICJzdHJ1
Y3QgbmxtX3dhaXQiIChha2EgImJsb2NrIikgaW4NCnN2Y2xvY2suYzpubG1z
dmNfY3JlYXRlX2Jsb2NrKCk7DQogICAgICAgIC8qIENyZWF0ZSBob3N0IGhh
bmRsZSBmb3IgY2FsbGJhY2sgKi8NCiAgICAgICAgaG9zdCA9IG5sbWNsbnRf
bG9va3VwX2hvc3QoJnJxc3RwLT5ycV9hZGRyLA0KICAgICAgICAgICAgICAg
ICAgICAgICAgcnFzdHAtPnJxX3Byb3QsIHJxc3RwLT5ycV92ZXJzKTsNCiAg
ICAgICAgLi4uDQogICAgICAgIC8qIENyZWF0ZSBhbmQgaW5pdGlhbGl6ZSB0
aGUgYmxvY2sgKi8NCiAgICAgICAgYmxvY2stPmJfZGFlbW9uID0gcnFzdHAt
PnJxX3NlcnZlcjsNCiAgICAgICAgYmxvY2stPmJfaG9zdCAgID0gaG9zdDsN
CiAgICAgICAgYmxvY2stPmJfZmlsZSAgID0gZmlsZTsNCiAgICAgICAgLi4u
DQogICAgICAgIC8qIFNldCB1cCBSUEMgYXJndW1lbnRzIGZvciBjYWxsYmFj
ayAqLw0KICAgICAgICBjYWxsID0gJmJsb2NrLT5iX2NhbGw7DQogICAgICAg
IGNhbGwtPmFfaG9zdCAgICA9IGhvc3Q7DQogICAgICAgIGNhbGwtPmFfZmxh
Z3MgICA9IFJQQ19UQVNLX0FTWU5DOw0KDQogIEhlcmUsIHRoZSBubG1jbG50
X2xvb2t1cF9ob3N0KCkgaXMgY3JlYXRpbmcgYW4gZW50cnkgaW4gdGhlIG5s
bV9ob3N0c1tdDQpjYWNoZSBmb3IgdGhlIGNsaWVudC4gIFRoaXMgaXMgY29y
cmVjdC4gIG5sbV9sb29rdXBfaG9zdCgpIHRha2VzIHRoZQ0KY2xpZW50J3Mg
YWRkcmVzcyAoc19hZGRyKSBmcm9tICZycXN0cC0+cnFfYWRkci4gIFRoZSBh
ZGRyZXNzIHdpbGwgYmUgbmVlZGVkDQp0byBjYWxsIHRoZSBjbGllbnQgYmFj
ayB3aXRoIGFuIE5MTV9HUkFOVEVELiAgbmxtY2xudF9sb29rdXBfaG9zdCgp
IGFsc28ga2VlcHMNCmEgcmVmZXJlbmNlIHRvIHRoZSBubG1faG9zdHNbXSBl
bnRyeSAoZm9yIHdoZW4gd2UncmUgcmVhZHkvYWJsZSB0byBzZW5kIHRoZQ0K
TkxNX0dSQU5URUQpLiAgQWxsIGdvb2Qgc3R1ZmYuDQoNCiAgQnV0IG5vdGUs
ICItPmJfaG9zdCIgaXMgc2V0IHRvICJob3N0Ii4gIFllcywgImhvc3QiIGlz
IGFuIGVudHJ5IGZvcg0KdGhlIGNsaWVudCBCVVQgaXQgaXMgYW4gZW50cnkg
Zm9yIHNlbmRpbmcgYW4gTkxNX0dSQU5URUQhICBUaGUgY2xpZW50DQp3aWxs
IGhhdmUgYSBkaWZmZXJlbnQgZW50cnkgaW4gbmxtX2hvc3RzW10gZm9yIGl0
cyBzZXJ2ZXItc2lkZSBvcGVyYXRpb25zLg0KICBUaGlzIGNhbiBiZSBjb25m
dXNpbmcgYXQgZmlyc3QuLi4uDQogIFRoZSBubG1faG9zdHNbXSBjYWNoZSBp
cyBvdmVybG9hZGVkIG9uIHRoZSBzZXJ2ZXIgc2lkZSAtIGl0IGNvbnRhaW5z
IHR3bw0KdHlwZXMgb2YgZW50cmllczsgb25lIHVzZWQgZm9yIGluY29taW5n
IHJlcXVlc3RzICh3aGljaCBhcmUgaW5kZXhlZCB2aWEgYQ0KY2xpZW50IHBv
aW50ZXIsIHdoaWNoIGNvbWVzIGZyb20gbmZzZCdzIGV4cG9ydCB0YWJsZSks
IGFuZCBvbmUgZm9yDQpOTE1fR1JBTlRFRCBhbmQgYXN5bmMgUlBDIGNhbGxi
YWNrcyAod2hpY2ggYXJlIGluZGV4ZWQgdmlhIHRoZSBjbGllbnQncw0KbmV0
d29yayBhZGRyZXNzKS4NCiAgV2h5IHR3byBkaWZmZXJlbnQgdHlwZXMgb2Yg
ZW50cnkgZm9yIHRoZSBzYW1lICd0aGluZyc/DQogICAgICAgIDEgRW50cmll
cyBpbmRleGVkIHZpYSBjbGllbnQgcG9pbnRlciBkbyBub3QgbmVlZCByZWZl
cmVuY2UNCiAgICAgICAgICBjb3VudGluZzsgdGhleSBleGlzdCB1bnRpbCB0
aGUgTkZTIHNlcnZlciB0ZWxscyBsb2NrZCB0byBmb3JnZXQNCiAgICAgICAg
ICBhYm91dCB0aGVtLiAgQXMgdGhlICdrZXknIChjbGllbnQgcHRyKSBjb21l
cyB2aWEgTkZTIGl0IGlzDQogICAgICAgICAgcGVyLWV4cG9ydC1wZXItY2xp
ZW50LiAgVGhpcyBpcyBpbXBvcnRhbnQsIGFzIGxvY2tkIG5lZWRzIHRoaXMN
CiAgICAgICAgICBleHRyYSAocGVyLWV4cG9ydCkgY29udGV4dCBmb3IgaXRz
IGNhY2hlcyAtIG90aGVyd2lzZSwgaXQgd291bGQNCiAgICAgICAgICBhbGwg
ZmFsbCBhcGFydC4gIChUaGluayBhYm91dCBhIGNsaWVudCBORlMgbW91bnRp
bmcgbW9yZSB0aGFuDQogICAgICAgICAgb25lIGV4cG9ydCBmcm9tIHRoZSBz
YW1lIHNlcnZlci4uLi4pDQogICAgICAgICAgTGV0cyBjYWxsIHRoZXNlIGVu
dHJpZXMgInBlci1leHBvcnQiIGNsaWVudCBlbnRyaWVzLg0KICAgICAgICAy
IEVudHJpZXMgaW5kZXhlZCB2aWEgYSBjbGllbnQncyBhZGRyZXNzIG5lZWQg
cmVmZXJlbmNpbmcgY291bnRpbmcsDQogICAgICAgICAgYW5kIGFyZSBpbmRl
cGVuZGVudCBvZiBORlMncyBleHBvcnQgY2FjaGUuDQogICAgICAgICAgQ2Fs
bCB0aGVzZSBlbnRyaWVzICJ0ZW1wb3JhcnkiIGNsaWVudCBlbnRyaWVzLg0K
DQogIE5vdywgIi0+Yl9ob3N0IiBpcyB1c2VkIHRocm91Z2h0IHRoZSBzZXJ2
ZXItc2lkZSBjb2RlIGFzIGEgcG9pbnRlciB0bw0KYSAndGVtcG9yYXJ5JyBj
bGllbnQgZW50cnkuICBFdmVyeXdoZXJlLCB0aGF0IGlzLCBleGNlcHQgZm9y
DQpubG1zdmNfdHJhdmVyc2VfYmxvY2tzKCkhICBubG1zdmNfdHJhdmVyc2Vf
YmxvY2tzKCkgaXMgKGNvcnJlY3RseSkgY2FsbGVkDQp3aXRoICdob3N0JyBy
ZWZlcmluZyB0byBhICdwZXItZXhwb3J0JyBjbGllbnQgZW50cnksIGJ1dCB0
aGUgdGVzdDsNCiAgICAgICAgaG9zdCA9PSBibG9jay0+Yl9ob3N0DQppcyBf
bm90XyBjb21wYXJpbmcgbGlrZS13aXRoLWxpa2UuICBJdCBpcyBjb21wYXJp
bmcgYSAndGVtcG9yYXJ5JyBlbnRyeQ0Kd2l0aCBhICdwZXItZXhwb3J0JyBl
bnRyeS4NCiAgQ2hhbmdpbmcgdGhlIGNvbXBhcmUgdG87DQogICAgICAgICBu
bG1fY21wX2FkZHIoJmhvc3QtPmhfYWRkciwgJmJsb2NrLT5iX2hvc3QtPmhf
YWRkcikNCmRvZXMgY2F1c2UgYSBtYXRjaCAoYXMgYm90aCBhbiAncGVyLWV4
cG9ydCcgYW5kICd0ZW1wb3JhcnknIGVudHJ5IHdpbGwNCmhhdmUgdGhlIHNh
bWUgY2xpZW50IElQIGFkZHJlc3MpLg0KICBCVVQsIGl0IGNhbiBhbHNvIGNh
dXNlIGZhbHNlLW5lZ2F0aXZlcyENCiAgVGhpbmsgb2YgdGhlIGNhc2Ugd2hl
cmUgYSBjbGllbnQgaGFzIG11bHRpcGxlIGV4cG9ydHMgbW91bnRlZCBmcm9t
IHRoZQ0Kc2VydmVyLiAgQ29tcGFyaW5nIGFkZHJlc3NlcyBvbmx5IGxvc2Vz
IHRoZSAncGVyLWV4cG9ydCcgY29udGV4dCAtIG5vdA0KZ29vZC4uLg0KDQog
IE5vdyBmb3IgYSBwb3NzaWJsZSBmaXgsIHdoaWNoIEkgaGF2ZW4ndCBmdWxs
IHRob3VnaHQgdGhyb3VnaCAocGVyaGFwcw0Kc29tZW9uZSBlbHNlIGNhbiBk
byB0aGlzIHBhcnQ/KS4NCiAgVGhlcmUgYXJlIG9ubHkgYSBmZXcgcGxhY2Vz
IGluIHRoZSBjb2RlIHdoZXJlICItPmJfaG9zdCIgaXMgdHJlYXRlZA0KYXMg
YSAndGVtcG9yYXJ5JyBjbGllbnQgZW50cnk7DQogICAgICAgIG5sbXN2Y19k
ZWxldGVfYmxvY2soKQ0KICAgICAgICAgICAgICAgIC0gdXNlZCB0byBjbGVh
ciB0aGUgY2FjaGVkIHZhbHVlIG9mIHRoZSBjbGllbnQncyBzaWRlIGxvY2tk
DQogICAgICAgICAgICAgICAgICBwb3J0IChsb2NrZCBjb3VsZCBoYXZlIGJl
ZW4gcmVzdGFydGVkIG9uIHRoZSBjbGllbnQsIGFuZA0KICAgICAgICAgICAg
ICAgICAgdGhlIHBvcnRtYXBwZXIgbmVlZHMgcXVlc3Rpb25pbmcgdG8gZmlu
ZCBpZiB0aGUgbG9ja2QNCiAgICAgICAgICAgICAgICAgIHBvcnQgaGFzIG1v
dmVkKQ0KICAgICAgICAgICAgICAgIC0gaGVyZSwgIi0+Yl9ob3N0IiBoYXMg
dGhlIHNhbWUgdmFsdWUgYXMNCiAgICAgICAgICAgICAgICAgICJibG9jay0+
Yl9jYWxsLmFfaG9zdCIuICBTaW1wbHkgdXNlIHRoaXMgdmFsdWUuDQogICAg
ICAgICAgICAgICAgLSAobm8gbmVlZCB0byB0ZXN0IGlmIHZhbHVlIGlzIHNl
dCAtIGl0IGFsd2F5cyB3aWxsIGJlKQ0KICAgICAgICBubG1zdmNfZ3JhbnRf
YmxvY2tlZCgpDQogICAgICAgICAgICAgICAgLSB1c2VkIHRvIHJlbGVhc2Ug
YSByZWZlcmVuY2Ugb24gdGhlICd0ZW1wb3JhcnknIGNsaWVudA0KICAgICAg
ICAgICAgICAgICAgZW50cnkgKHVzZWQgZm9yIHNlbmRpbmcgYW4gTkxNX0dS
QU5URUQpLg0KICAgICAgICAgICAgICAgIC0gdGhpcywgYWdhaW4sIGNhbiBi
ZSByZXBsYWNlZCB3aXRoIHRoZSB2YWx1ZTsNCiAgICAgICAgICAgICAgICAg
ICJibG9jay0+Yl9jYWxsLmFfaG9zdCINCiAgTm90ZTogTmVlZCB0byBkb3Vi
bGUgY2hlY2sgdGhlICJhX2hvc3QiIGlzIG5vdCBzY3JpYmJsZWQgb3ZlciB3
aXRoIGFuDQogICAgICAgIFJQQyBjYWxsLCBidXQgaWYgaXQgaXMgdGhlbiB0
aGUgY3VycmVudCBjb2RlIHdpbGwgaGF2ZSBwcm9ibGVtcy4uLg0KDQogIEFz
IHRoZSBvbmx5IHJlbWFpbmluZyB1c2Ugb2YgIi0+Yl9ob3N0IiBpcyB0byB0
ZWFyZG93biAibmxtX2Jsb2NrInMNCmR1cmluZyBhbiB1bmV4cG9ydCwgdGhl
biBzZXR0aW5nIGl0IHRvIHRoZSAncGVyLWV4cG9ydCcgY2xpZW50IGVudHJ5
DQppbiBubG1zdmNfY3JlYXRlX2Jsb2NrKCkgc2hvdWxkIHNvbHZlIGFsbCB0
aGUgcHJvYmxlbXM7DQogICAgICAgIGJsb2NrLT5iX2hvc3QgPSBubG1zdmNf
bG9va3VwX2hvc3QocnFzdHApOw0KICAgICAgICBpZiAoYmxvY2stPmJfaG9z
dCA9PSBOVUxMKSB7DQogICAgICAgICAgICAgICAgbmxtY2xudF9mcmVlZ3Jh
bnRhcmdzKCZibG9jay0+Yl9jYWxsKTsNCiAgICAgICAgICAgICAgICBnb3Rv
IGZhaWxlZF9mcmVlOw0KICAgICAgICB9DQooYWN0dWFsbHksIGJlc3QgdG8g
bW92ZSBzZXR0aW5nIG9mIGJfaG9zdCB0byBiZWZvcmUgbmxtY2xudF9zZXRn
cmFudGFyZ3MoKSwNCnJlbW92aW5nIHRoZSBuZWVkIGZvciBubG1jbG50X2Zy
ZWVncmFudGFyZ3MoKSkNCg==
--8323328-886247951-1060169279=:1062--


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
