From: Bernhard Kaindl <bk@suse.de>
Subject: Re: NFS oopses on smp servers
Date: Mon, 16 Dec 2002 15:38:04 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0212161226020.8807-300000@wotan.suse.de>
References: <E18NaDc-000MXq-00@f20.mail.ru>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="168427776-609808995-1040045453=:11063"
Cc: <nfs@lists.sourceforge.net>, Chris Mason <mason@suse.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.suse.de ([213.95.15.193] helo=Cantor.suse.de)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NwNj-00052x-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 06:38:08 -0800
To: Peter Lojkin <ia6432@inbox.ru>
In-Reply-To: <E18NaDc-000MXq-00@f20.mail.ru>
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

--168427776-609808995-1040045453=:11063
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.33.0212161452161.11063@wotan.suse.de>

On Sun, 15 Dec 2002, Peter Lojkin wrote:

> we keep getting nfs related oopses on our servers. we tried stock
[Trace reformatted for better reading:]
> EIP:    0010:[nfs_release_request+137/180]
> [nfs_try_to_free_pages+268/288]
> [nfs_create_request+168/288]
> [nfs_update_request+544/828]
> [nfs_updatepage+165/516]
> [nfs_commit_write+63/108]
> Code: 8b 00 85 c0 7d 08 0f 0b a9 00 52 0c 2a c0 53 e8 0b ff ff ff

Hi,
   we've nailed an identical looking oops which we were able to reproduce
also with a 8-CPU Machine running the NFS-Client under extreme load, it
happened also with 2.4.20-NFS-ALL without any other patch in addition.

Chris Mason found the cause for this oops, I've attached his patch with
enhanced description from me. I've only tested the other, smaller diff
extensively(2nd, smaller attachment), but the patch from Chris should
be ok as well.

Configuration:

NFS client: Dell PowerEdge 6650, eight(8) 1.6GHz Xeon Processors, 4GB RAM
NFS server: Network Appliance NetApp F825(Storage Appliance, high-perf)
Network:    Direct crossover 1000Mbit Ethernet without switch using Fiber.

With this configuration I was able to trigger within one hour after starting
an extreme load test reaching a load of >45 on the NFS-Client only doing
NFS Work(setting up ~1GB chroot environments and compiling in them, many
many in parallel)

Problem description:

The problem is that nfs_clear_request and nfs_release_request
contain accesses to the file's inode which are done after the
fput of the file which could have freed the inode also.

In extreme circumstances the inode pointer used for these accesses
could point to reused/cleared memory which would lead to an oops.

Fix discussion:

The idea of the fix is to not to fput the file until the request
is completely gone.

The fput needs to be done after the the last access to the inode
because the fput could free the inode also.

There are two different ways to do it, one would be to change
nfs_clear_request to not do an fput at all, and do the fput in
nfs_release_request.

But since nfs_release_request calls nfs_clear_request, it looks
like nfs_clear_request wasn't intended to be called separately
at a few places before nfs_release_request is called.

So the calls to nfs_clear_request before nfs_release_request
should be removed, nfs_release_request calls nfs_clear_request
itself at the right time after the last cleanup and the consisteny
checks.

To achieve this completely, nfs_clear_request must be also
reordered to do the fput last since the unpatched code accesses
the inode after the fput which can also lead to an oops on SMP
under extreme conditions.

Patch Description:
------------------

Remove the calls to nfs_clear_request before nfs_release_request,
to avoid freeing the file in nfs_clear_request because this could
also free the inode which is then accessed in nfs_release_request
directly afterwards.

Also reorder nfs_clear_request to do the fput last, since
the unpatched code accesses the inode after the fput.

This patch also changes nfs_clear_request to static and removes
the extern declaration, because it's not called from outside of
pagelist.o anymore after the diff applied.

Possible Improvement after applying the patch:
----------------------------------------------

In a second step, the code from nfs_clear_request could
be moved to nfs_release_request to reduce code size and
number of instructions since nfs_release_request should
be the only caller of nfs_clear_request then.

Best Regards,
Bernhard Kaindl
UnitedLinux Development
SuSE Linux - www.suse.com

PS: Other sample traces from this test/oops (different kernels)

>>EIP; c0197001 <nfs_release_request+101/130>   <=====
Trace; c0197616 <nfs_try_to_free_pages+36/240>
Trace; c0196e21 <nfs_create_request+b1/120>
Trace; c019b006 <nfs_update_request+126/490>
Trace; c019b3cc <nfs_strategy+5c/70>
Trace; c019b578 <nfs_updatepage+c8/2c0>
Trace; c0192c72 <nfs_commit_write+72/d0>
Trace; c013cf15 <generic_file_write+495/800>
Trace; c0192dc8 <nfs_file_write+98/100>
Trace; c014da67 <sys_write+97/1d0>
Trace; c010984f <system_call+33/38>

>>EIP; c01a48ce <nfs_release_request+8e/c0>   <=====
Trace; c01a4ef6 <nfs_try_to_free_pages+36/150>
Trace; c02613cc <skb_copy_datagram_iovec+4c/280>
Trace; c01a4768 <nfs_create_request+a8/110>
Trace; c025f0f6 <__kfree_skb+106/170>
Trace; c01a85d1 <nfs_update_request+c1/350>
Trace; c01a8a3e <nfs_updatepage+9e/270>
Trace; c0143067 <do_generic_file_write+447/7e0>
Trace; c025b098 <sock_recvmsg+58/f0>
Trace; c014349b <generic_file_write+9b/d0>
Trace; c01a0aab <nfs_file_write+bb/140>
Trace; c0154c47 <sys_write+97/140>
Trace; c01095ef <system_call+33/38>

Code;  c01a48ce <nfs_release_request+8e/c0>
00000000 <_EIP>:
Code;  c01a48ce <nfs_release_request+8e/c0>   <=====
   0:   8b 00                     mov    (%eax),%eax   <=====
Code;  c01a48d0 <nfs_release_request+90/c0>
   2:   85 c0                     test   %eax,%eax
Code;  c01a48d2 <nfs_release_request+92/c0>
   4:   78 1e                     js     24 <_EIP+0x24> c01a48f2 <nfs_release_r
equest+b2/c0>
Code;  c01a48d4 <nfs_release_request+94/c0>
   6:   89 1c 24                  mov    %ebx,(%esp,1)
Code;  c01a48d7 <nfs_release_request+97/c0>
   9:   e8 f4 fe ff ff            call   ffffff02 <_EIP+0xffffff02> c01a47d0 <n
fs_clear_request+0/70>
Code;  c01a48dc <nfs_release_request+9c/c0>
   e:   a1 04 15 42 c0            mov    0xc0421504,%eax
Code;  c01a48e1 <nfs_release_request+a1/c0>
  13:   89 00                     mov    %eax,(%eax)

--168427776-609808995-1040045453=:11063
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME=mason-nfs_clear_request-fput
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0212161525200.11063@wotan.suse.de>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=mason-nfs_clear_request-fput

UGF0Y2ggYW5kIG9yaWdpbmFsIHNob3J0IERlc2NyaXB0aW9uIGZyb20gQ2hy
aXMgTWFzb24sDQpEZXNjcmlwdGlvbiBleHRlbmRlZCBieSBCZXJuaGFyZCBL
YWluZGwsIGJvdGggU3VTRS4NCg0KU3ltcHRvbToNCi0tLS0tLS0tDQoNCk9v
cHNlcyBpbiBuZnNfY2xlYXJfcmVxdWVzdCBhbmQgbmZzX3JlbGVhc2VfcmVx
dWVzdChORlMtQ2xpZW50KQ0KdW5kZXIgZXh0cmVtZSBDaXJjdW1zdGFuY2Vz
IG9uIFNNUC1NYWNoaW5lcyhoYXBwZW5lZCB3aXRoIDQgQ1BVcykNCg0KUHJv
YmxlbToNCi0tLS0tLS0tDQoNCm5mc19jbGVhcl9yZXF1ZXN0IGFuZCBuZnNf
cmVsZWFzZV9yZXF1ZXN0IGNvbnRhaW4gYWNjZXNzZXMNCnRvIHRoZSBmaWxl
J3MgaW5vZGUgd2hpY2ggYXJlIGRvbmUgYWZ0ZXIgdGhlIGZwdXQgb2YgdGhl
DQpmaWxlIHdoaWNoIGNvdWxkIGhhdmUgZnJlZWQgdGhlIGlub2RlIGFsc28u
DQoNCkluIGV4dHJlbWUgY2lyY3Vtc3RhbmNlcyB0aGUgaW5vZGUgcG9pbnRl
ciB1c2VkIGZvciB0aGVzZSBhY2Nlc3Nlcw0KY291bGQgcG9pbnQgdG8gcmV1
c2VkL2NsZWFyZWQgbWVtb3J5IHdoaWNoIHdvdWxkIGxlYWQgdG8gYW4gb29w
cy4NCg0KU29sdXRpb246DQotLS0tLS0tLS0NCg0KVGhlIGlkZWEgb2YgdGhl
IGZpeCBpcyB0byBub3QgdG8gZnB1dCB0aGUgZmlsZSB1bnRpbCB0aGUgcmVx
dWVzdA0KaXMgY29tcGxldGVseSBnb25lLg0KDQpUaGUgZnB1dCBuZWVkcyB0
byBiZSBkb25lIGFmdGVyIHRoZSB0aGUgbGFzdCBhY2Nlc3MgdG8gdGhlIGlu
b2RlDQpiZWNhdXNlIHRoZSBmcHV0IGNvdWxkIGZyZWUgdGhlIGlub2RlIGFs
c28uDQoNClRoZXJlIGFyZSB0d28gZGlmZmVyZW50IHdheXMgdG8gZG8gaXQs
IG9uZSB3b3VsZCBiZSB0byBjaGFuZ2UNCm5mc19jbGVhcl9yZXF1ZXN0IHRv
IG5vdCBkbyBhbiBmcHV0IGF0IGFsbCwgYW5kIGRvIHRoZSBmcHV0IGluDQpu
ZnNfcmVsZWFzZV9yZXF1ZXN0LiANCg0KQnV0IHNpbmNlIG5mc19yZWxlYXNl
X3JlcXVlc3QgY2FsbHMgbmZzX2NsZWFyX3JlcXVlc3QsIGl0IGxvb2tzDQps
aWtlIG5mc19jbGVhcl9yZXF1ZXN0IHdhc24ndCBpbnRlbmRlZCB0byBiZSBj
YWxsZWQgc2VwYXJhdGVseQ0KYXQgYSBmZXcgcGxhY2VzIGJlZm9yZSBuZnNf
cmVsZWFzZV9yZXF1ZXN0IGlzIGNhbGxlZC4NCg0KU28gdGhlIGNhbGxzIHRv
IG5mc19jbGVhcl9yZXF1ZXN0IGJlZm9yZSBuZnNfcmVsZWFzZV9yZXF1ZXN0
DQpzaG91bGQgYmUgcmVtb3ZlZCwgbmZzX3JlbGVhc2VfcmVxdWVzdCBjYWxs
cyBuZnNfY2xlYXJfcmVxdWVzdA0KaXRzZWxmIGF0IHRoZSByaWdodCB0aW1l
IGFmdGVyIHRoZSBsYXN0IGNsZWFudXAgYW5kIHRoZSBjb25zaXN0ZW55DQpj
aGVja3MuDQoNClRvIGFjaGlldmUgdGhpcyBjb21wbGV0ZWx5LCBuZnNfY2xl
YXJfcmVxdWVzdCBtdXN0IGJlIGFsc28NCnJlb3JkZXJlZCB0byBkbyB0aGUg
ZnB1dCBsYXN0IHNpbmNlIHRoZSB1bnBhdGNoZWQgY29kZSBhY2Nlc3Nlcw0K
dGhlIGlub2RlIGFmdGVyIHRoZSBmcHV0IHdoaWNoIGNhbiBhbHNvIGxlYWQg
dG8gYW4gb29wcyBvbiBTTVANCnVuZGVyIGV4dHJlbWUgY29uZGl0aW9ucy4N
Cg0KUGF0Y2ggRGVzY3JpcHRpb246DQotLS0tLS0tLS0tLS0tLS0tLS0NCg0K
UmVtb3ZlIHRoZSBjYWxscyB0byBuZnNfY2xlYXJfcmVxdWVzdCBiZWZvcmUg
bmZzX3JlbGVhc2VfcmVxdWVzdCwNCnRvIGF2b2lkIGZyZWVpbmcgdGhlIGZp
bGUgaW4gbmZzX2NsZWFyX3JlcXVlc3QgYmVjYXVzZSB0aGlzIGNvdWxkDQph
bHNvIGZyZWUgdGhlIGlub2RlIHdoaWNoIGlzIHRoZW4gYWNjZXNzZWQgaW4g
bmZzX3JlbGVhc2VfcmVxdWVzdA0KZGlyZWN0bHkgYWZ0ZXJ3YXJkcy4NCg0K
QWxzbyByZW9yZGVyIG5mc19jbGVhcl9yZXF1ZXN0IHRvIGRvIHRoZSBmcHV0
IGxhc3QsIHNpbmNlDQp0aGUgdW5wYXRjaGVkIGNvZGUgYWNjZXNzZXMgdGhl
IGlub2RlIGFmdGVyIHRoZSBmcHV0Lg0KDQpUaGlzIHBhdGNoIGFsc28gY2hh
bmdlcyBuZnNfY2xlYXJfcmVxdWVzdCB0byBzdGF0aWMgYW5kIHJlbW92ZXMN
CnRoZSBleHRlcm4gZGVjbGFyYXRpb24sIGJlY2F1c2UgaXQncyBub3QgY2Fs
bGVkIGZyb20gb3V0c2lkZSBvZg0KcGFnZWxpc3QubyBhbnltb3JlIGFmdGVy
IHRoZSBkaWZmIGFwcGxpZWQuDQoNClBvc3NpYmxlIEltcHJvdmVtZW50IGFm
dGVyIGFwcGx5aW5nIHRoaXMgcGF0Y2g6DQotLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCg0KSW4gYSBzZWNvbmQg
c3RlcCwgdGhlIGNvZGUgZnJvbSBuZnNfY2xlYXJfcmVxdWVzdCBjb3VsZA0K
YmUgbW92ZWQgdG8gbmZzX3JlbGVhc2VfcmVxdWVzdCB0byByZWR1Y2UgY29k
ZSBzaXplIGFuZA0KbnVtYmVyIG9mIGluc3RydWN0aW9ucyBzaW5jZSBuZnNf
cmVsZWFzZV9yZXF1ZXN0IHNob3VsZA0KYmUgdGhlIG9ubHkgY2FsbGVyIG9m
IG5mc19jbGVhcl9yZXF1ZXN0IHRoZW4uDQoNCi0tLSBsaW51eC0yLjQuMTku
U3VTRS9mcy9uZnMvcGFnZWxpc3QuYw0KKysrIGxpbnV4LTIuNC4xOS5TdVNF
L2ZzL25mcy9wYWdlbGlzdC5jDQpAQCAtMTIyLDEzICsxMjIsOCBAQA0KICAq
IFJlbGVhc2UgYWxsIHJlc291cmNlcyBhc3NvY2lhdGVkIHdpdGggYSB3cml0
ZSByZXF1ZXN0IGFmdGVyIGl0DQogICogaGFzIGNvbXBsZXRlZC4NCiAgKi8N
Ci12b2lkIG5mc19jbGVhcl9yZXF1ZXN0KHN0cnVjdCBuZnNfcGFnZSAqcmVx
KQ0KK3N0YXRpYyB2b2lkIG5mc19jbGVhcl9yZXF1ZXN0KHN0cnVjdCBuZnNf
cGFnZSAqcmVxKQ0KIHsNCi0JLyogUmVsZWFzZSBzdHJ1Y3QgZmlsZSBvciBj
YWNoZWQgY3JlZGVudGlhbCAqLw0KLQlpZiAocmVxLT53Yl9maWxlKSB7DQot
CQlmcHV0KHJlcS0+d2JfZmlsZSk7DQotCQlyZXEtPndiX2ZpbGUgPSBOVUxM
Ow0KLQl9DQogCWlmIChyZXEtPndiX2NyZWQpIHsNCiAJCXB1dF9ycGNjcmVk
KHJlcS0+d2JfY3JlZCk7DQogCQlyZXEtPndiX2NyZWQgPSBOVUxMOw0KQEAg
LTEzOCw2ICsxMzMsMTMgQEANCiAJCXJlcS0+d2JfcGFnZSA9IE5VTEw7DQog
CQlhdG9taWNfZGVjKCZORlNfUkVRVUVTVExJU1QocmVxLT53Yl9pbm9kZSkt
Pm5yX3JlcXVlc3RzKTsNCiAJfQ0KKwkvKiBSZWxlYXNlIHN0cnVjdCBmaWxl
IG9yIGNhY2hlZCBjcmVkZW50aWFsLCBkbyBpdCBsYXN0IHNpbmNlIGl0DQor
CSAqIGNhbiBpcHV0DQorCSAqLw0KKwlpZiAocmVxLT53Yl9maWxlKSB7DQor
CQlmcHV0KHJlcS0+d2JfZmlsZSk7DQorCQlyZXEtPndiX2ZpbGUgPSBOVUxM
Ow0KKwl9DQogfQ0KIA0KDQotLS0gbGludXgtMi40LjE5LlN1U0UvZnMvbmZz
L3JlYWQuYw0KKysrIGxpbnV4LTIuNC4xOS5TdVNFL2ZzL25mcy9yZWFkLmMN
CkBAIC0yMjIsNyArMjIyLDYgQEANCiAJCW5mc19saXN0X3JlbW92ZV9yZXF1
ZXN0KHJlcSk7DQogCQlTZXRQYWdlRXJyb3IocGFnZSk7DQogCQlVbmxvY2tQ
YWdlKHBhZ2UpOw0KLQkJbmZzX2NsZWFyX3JlcXVlc3QocmVxKTsNCiAJCW5m
c19yZWxlYXNlX3JlcXVlc3QocmVxKTsNCiAJCW5mc191bmxvY2tfcmVxdWVz
dChyZXEpOw0KIAl9DQpAQCAtNDI4LDcgKzQyNyw2IEBADQogICAgICAgICAg
ICAgICAgICAgICAgICAgKGxvbmcgbG9uZylORlNfRklMRUlEKHJlcS0+d2Jf
aW5vZGUpLA0KICAgICAgICAgICAgICAgICAgICAgICAgIHJlcS0+d2JfYnl0
ZXMsDQogICAgICAgICAgICAgICAgICAgICAgICAgKGxvbmcgbG9uZykocGFn
ZV9vZmZzZXQocGFnZSkgKyByZXEtPndiX29mZnNldCkpOw0KLQkJbmZzX2Ns
ZWFyX3JlcXVlc3QocmVxKTsNCiAJCW5mc19yZWxlYXNlX3JlcXVlc3QocmVx
KTsNCiAJCW5mc191bmxvY2tfcmVxdWVzdChyZXEpOw0KIAl9DQotLS0gbGlu
dXgtMi40LjE5LlN1U0UvZnMvbmZzL3dyaXRlLmMNCisrKyBsaW51eC0yLjQu
MTkuU3VTRS9mcy9uZnMvd3JpdGUuYw0KQEAgLTMzOCw3ICszMzgsNiBAQA0K
IAkJaXB1dChpbm9kZSk7DQogCX0gZWxzZQ0KIAkJc3Bpbl91bmxvY2soJm5m
c193cmVxX2xvY2spOw0KLQluZnNfY2xlYXJfcmVxdWVzdChyZXEpOw0KIAlu
ZnNfcmVsZWFzZV9yZXF1ZXN0KHJlcSk7DQogfQ0KIA0KLS0tIGxpbnV4LTIu
NC4xOS5TdVNFL2luY2x1ZGUvbGludXgvbmZzX3BhZ2UuaA0KKysrIGxpbnV4
LTIuNC4xOS5TdVNFL2luY2x1ZGUvbGludXgvbmZzX3BhZ2UuaA0KQEAgLTQ0
LDcgKzQ0LDYgQEANCiBleHRlcm4Jc3RydWN0IG5mc19wYWdlICpuZnNfY3Jl
YXRlX3JlcXVlc3Qoc3RydWN0IHJwY19jcmVkICosIHN0cnVjdCBpbm9kZSAq
LA0KIAkJCQkJICAgIHN0cnVjdCBwYWdlICosDQogCQkJCQkgICAgdW5zaWdu
ZWQgaW50LCB1bnNpZ25lZCBpbnQpOw0KLWV4dGVybgl2b2lkIG5mc19jbGVh
cl9yZXF1ZXN0KHN0cnVjdCBuZnNfcGFnZSAqcmVxKTsNCiBleHRlcm4Jdm9p
ZCBuZnNfcmVsZWFzZV9yZXF1ZXN0KHN0cnVjdCBuZnNfcGFnZSAqcmVxKTsN
CiANCg0K
--168427776-609808995-1040045453=:11063
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME=nfs_clear_request-fput
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0212161525201.11063@wotan.suse.de>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=nfs_clear_request-fput

IyBOb3RlLCB0aGlzIGlzIHRoZSBtaW5pbXVtIGRpZmYgd2hpY2ggSShiaykg
dGVzdGVkIGV4dGVuc2l2bHkNCiMgb24gemVydDE4NSB3aXRoIHRoZSBOZXR3
b3JrIEFwcGxpYW5jZSBOZXRBcHAxODUgYXMgTkZTLVNlcnZlci4NCg0KU3lt
cHRvbToNCi0tLS0tLS0tDQoNCk9vcHNlcyBpbiBuZnNfY2xlYXJfcmVxdWVz
dCBhbmQgbmZzX3JlbGVhc2VfcmVxdWVzdChORlMtQ2xpZW50KQ0KdW5kZXIg
ZXh0cmVtZSBDaXJjdW1zdGFuY2VzIG9uIFNNUC1NYWNoaW5lcyhoYXBwZW5l
ZCB3aXRoIDQgQ1BVcykNCg0KUHJvYmxlbToNCi0tLS0tLS0tDQoNCm5mc19j
bGVhcl9yZXF1ZXN0IGFuZCBuZnNfcmVsZWFzZV9yZXF1ZXN0IGNvbnRhaW4g
YWNjZXNzZXMNCnRvIHRoZSBmaWxlJ3MgaW5vZGUgd2hpY2ggYXJlIGRvbmUg
YWZ0ZXIgdGhlIGZwdXQgb2YgdGhlDQpmaWxlIHdoaWNoIGNvdWxkIGZyZWUg
dGhlIGlub2RlIGFsc28uDQoNClNvbHV0aW9uIC8gUGF0Y2ggRGVzY3JpcHRp
b246DQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KDQpSZW1vdmUg
dGhlIGNhbGxzIHRvIG5mc19jbGVhcl9yZXF1ZXN0IGJlZm9yZSBuZnNfcmVs
ZWFzZV9yZXF1ZXN0LA0KdG8gYXZvaWQgZnJlZWluZyB0aGUgZmlsZSBpbiBu
ZnNfY2xlYXJfcmVxdWVzdCBiZWNhdXNlIHRoaXMgY291bGQNCmFsc28gZnJl
ZSB0aGUgaW5vZGUgd2hpY2ggaXMgdGhlbiBhY2Nlc3NlZCBpbiBuZnNfcmVs
ZWFzZV9yZXF1ZXN0DQpkaXJlY3RseSBhZnRlcndhcmRzLg0KDQpBbHNvIHJl
b3JkZXIgbmZzX2NsZWFyX3JlcXVlc3QgdG8gZG8gdGhlIGZwdXQgbGFzdCwg
c2luY2UNCnRoZSB1bnBhdGNoZWQgY29kZSBhY2Nlc3NlcyB0aGUgaW5vZGUg
YWZ0ZXIgdGhlIGZwdXQuDQoNClNpZGUgTm90ZXM6DQotLS0tLS0tLS0tLQ0K
DQpQYXRjaCBmb3IgbmZzX2NsZWFyX3JlcXVlc3QgZnJvbSBDaHJpcyBNYXNv
biwgZnVsbCBwYXRjaCBmcm9tIENocmlzIGRpZA0KYWxzbyByZW1vdmUgbmZz
X2NsZWFyX3JlcXVlc3QgZnJvbSBhIGZldyBwbGFjZXMsIHRoaXMgcGF0Y2gg
b25seQ0KcmVtb3ZlcyB0aGUgcmVtYWluaW5nIGlub2RlIGRlYnVnLXBhcmFu
b2lhIGNoZWNrIGZyb20gbmZzX3JlbGVhc2VfcmVxdWVzdA0Kd2hpY2ggd291
bGQgaGF2ZSBhbHNvIGJlZW4gZG9uZSBhZnRlciB0aGUgZnB1dC4NCg0KVGhp
cyBpcyB0aGUgbWluaW11bSBQYXRjaCwgdGhlIG9yaWdpbmFsIGZpeCtjbGVh
bnVwIGZyb20gQ2hyaXMgTWFzb24gYWxzbw0KcmVtb3ZlZCB0aGUgY2FsbCBv
ZiBuZnNfY2xlYXJfcmVxdWVzdCBiZWZvcmUgbmZzX3JlbGVhc2VfcmVxdWVz
dCwgaW4NCnNvbWUgcGxhY2VzIHdoaWNoIG1lYW5zIHRoYXQgdGhlIG5mc19j
bGVhcl9yZXF1ZXN0IGNhbGwgaW5zaWRlIA0KbmZzX3JlbGVhc2VfcmVxdWVz
dCBiZWNvbWVzIHRoZSAnaG90JyBjYWxsIHRvIG5mc19jbGVhcl9yZXF1ZXN0
DQphbmQgbmZzX2NsZWFyX3JlcXVlc3QgY2FuIHRoZW4gYWxzbyBiZSBpbnRl
Z3JhdGVkIGludG8gbmZzX3JlbGVhc2VfcmVxdWVzdA0Kc2luY2UgdGhpcyBz
aG91bGQgYmUgdGhlIG9ubHkgcGxhY2Ugd2hlcmUgbmZzX2NsZWFyX3JlcXVl
c3QgaXMgY2FsbGVkIHRoZW4uDQoNCi0tLSBsL2ZzL25mcy9wYWdlbGlzdC5j
DQorKysgbC9mcy9uZnMvcGFnZWxpc3QuYw0KQEAgLTEyNCwxMSArMTI0LDYg
QEANCiAgKi8NCiB2b2lkIG5mc19jbGVhcl9yZXF1ZXN0KHN0cnVjdCBuZnNf
cGFnZSAqcmVxKQ0KIHsNCi0JLyogUmVsZWFzZSBzdHJ1Y3QgZmlsZSBvciBj
YWNoZWQgY3JlZGVudGlhbCAqLw0KLQlpZiAocmVxLT53Yl9maWxlKSB7DQot
CQlmcHV0KHJlcS0+d2JfZmlsZSk7DQotCQlyZXEtPndiX2ZpbGUgPSBOVUxM
Ow0KLQl9DQogCWlmIChyZXEtPndiX2NyZWQpIHsNCiAJCXB1dF9ycGNjcmVk
KHJlcS0+d2JfY3JlZCk7DQogCQlyZXEtPndiX2NyZWQgPSBOVUxMOw0KQEAg
LTEzOCw2ICsxMzMsMTEgQEANCiAJCXJlcS0+d2JfcGFnZSA9IE5VTEw7DQog
CQlhdG9taWNfZGVjKCZORlNfUkVRVUVTVExJU1QocmVxLT53Yl9pbm9kZSkt
Pm5yX3JlcXVlc3RzKTsNCiAJfQ0KKwkvKiByZWxlYXNlIGZpbGUgbGFzdCBz
aW5jZSBpdCBjYW4gaXB1dCAqLw0KKwlpZiAocmVxLT53Yl9maWxlKSB7DQor
CQlmcHV0KHJlcS0+d2JfZmlsZSk7DQorCQlyZXEtPndiX2ZpbGUgPSBOVUxM
Ow0KKwl9DQogfQ0KIA0KIA0KQEAgLTE2NSw4ICsxNjUsNiBAQA0KIAkJQlVH
KCk7DQogCWlmIChORlNfV0JBQ0tfQlVTWShyZXEpKQ0KIAkJQlVHKCk7DQot
CWlmIChhdG9taWNfcmVhZCgmTkZTX1JFUVVFU1RMSVNUKHJlcS0+d2JfaW5v
ZGUpLT5ucl9yZXF1ZXN0cykgPCAwKQ0KLQkJQlVHKCk7DQogI2VuZGlmDQog
DQogCS8qIFJlbGVhc2Ugc3RydWN0IGZpbGUgb3IgY2FjaGVkIGNyZWRlbnRp
YWwgKi8NCg==
--168427776-609808995-1040045453=:11063--


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
