From: "In-Sun Song" <sis@atmos.yonsei.ac.kr>
Subject: NFS and file system error
Date: Sat, 14 Sep 2002 09:03:58 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <FCEJLDBIGGMAGABAPIKLOEFMCBAA.sis@atmos.yonsei.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Cc: "=?ks_c_5601-1987?B?wMwgx/XBpg==?=" <lhj@atmos.yonsei.ac.kr>,
        "=?ks_c_5601-1987?B?wK8gwda5zA==?=" <rjm@atmos.yonsei.ac.kr>,
        "=?ks_c_5601-1987?B?seggvNK/tQ==?=" <soyoung@atmos.yonsei.ac.kr>,
        "=?ks_c_5601-1987?B?sO0gwaS8rg==?=" <illian@atmos.yonsei.ac.kr>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from atmos.yonsei.ac.kr ([134.75.155.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17q0OX-0006bC-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Sep 2002 17:02:41 -0700
To: <nfs@lists.sourceforge.net>
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

RGVhciBORlMgdXNlcnMNCg0KSSB1c2UgTElOVVggc2VydmVyIChSZWRoYXQgNy4yIGtlcm5lbCB2
ZXJzaW9uIDIuNC43LTEwKSBhcyBhIE5GUyANCmZpbGUgc2VydmVyLiBJIHVzZSBDb21wYXEgYWxw
aGEgd29ya3N0YXRpb24gYXMgYSBORlMgY2xpZW50IG1hY2hpbmUuDQoNCkkgdXN1YWxseSBydW4g
YSBwcm9ncmFtIG9uIHRoZSBhbHBoYSB3b3Jrc3RhdGlvbiBhbmQgZHVtcCBvdXRwdXQNCmZpbGVz
IHRvIHRoZSBMSU5VWCBzZXJ2ZXIgdXNpbmcgTkZTLg0KV2hlbiBJIHdyaXRlIGEgbG90IG9mIGZp
bGVzICh0aGUgZmlsZSBzaXplIG9mIGVhY2ggZmlsZSBpcyBsZXNzIHRoYW4gMSBNQiksDQp0aGUg
TElOVVggZmlsZXNlcnZlciBkb2Vzbid0IG9mdGVuIHdvcmssIGFuZCB0aGUgc3lzdGVtIHNlbmRz
IHRoZSBmb2xsb3dpbmcNCmVycm9ycyBtZXNzYWdlcyBvbiB0aGUgdGVybWluYWwuDQoNCi9ob21l
NSBjb250YWlucyBhIGZpbGUgc3lzdGVtIHdpdGggZXJyb3JzLCBjaGVjayBmb3JjZWQuIA0KL2hv
bWU1OiA2OTg4Ni8xMjIyMjQ2NCBmaWxlcyAoOTYuOSUgbm9uLWNvbnRpZ3VvdXMpIC4uLi4NCg0K
SWYgSSB1c2UgImZzY2siIHRvIGNoZWNrIHRoZSBmaWxlIHN5c3RlbSB3aXRoIGVycm9ycywgdGhl
IExJTlVYIHN5c3RlbQ0Kc2hvd3MgdGhlIGZvbGxvd2luZyBtZXNzYWdlcy4NCg0KZnNjazogRHVw
bGljYXRlIGJsb2NrcyBmb3VuZC4uLiBpbnZva2luZyBkdXBsaWNhdGUgYmxvY2sgcGFzc2VzLg0K
ZnNjazogUGFzcyAxQjogUmVzY2FuIGZvciBkdXBsaWNhdGUvYmFkIGJsb2Nrcw0KZnNjazogL2hv
bWU1Og0KZnNjazogUGFzcyAxQzogU2NhbiBkaXJlY3RvcmllcyBmb3IgaW5vZGVzIHdpdGggZHVw
IGJsb2Nrcw0KZnNjazogL2hvbWU1Og0KZnNjazogUGFzcyAxRDogUmVjb25jaWxpbmcgZHVwbGlj
YXRlIGJsb2Nrcw0KZnNjazogL2hvbWU1Og0KZnNjazogKFRoZXJlIGFyZSAxIGlub2RlcyBjb250
YWluaW5nIGR1cGxpY2F0ZS9iYWQgYmxvY2tzLikNCi4uLi4uLi4uLi4uLiANCg0KSXMgdGhpcyBw
cm9ibGVtIHJlbGF0ZWQgdG8gY29uZmlndXJhdGlvbnMgb2YgTkZTIG1vdW50IG9uIExJTlVYIHNl
cnZlcj8gb3INClJlZGhhdCA3LjIgYnVncz8NCg0KSGF2ZSB5b3UgZXZlciBleHBlcmllbmNlZCBw
cm9ibGVtcyBsaWtlIHRoZXNlPw0KDQoNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LQ0KSW4tU3VuIFNvbmcNClBoLiBELiBzdHVkZW50DQpMYWJvcmF0b3J5IGZvciBNZXNvc2NhbGUg
RHluYW1pY3MNCkRlcGFydG1lbnQgb2YgQXRtb3NwaGVyaWMgU2NpZW5jZXMNClNoaW5jaG9uLWRv
bmcgMTM0LCBTZW9kYWVtdW4ta3UNCllvbnNlaSBVbml2ZXJzaXR5LCBTZW91bCAxMjAtNzQ5LCBL
b3JlYQ0KRS1tYWlsIDogc2lzQGF0bW9zLnlvbnNlaS5hYy5rcg0KSG9tZXBhZ2U6IGh0dHA6Ly9t
ZXNvZHluLnlvbnNlaS5hYy5rcg==



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
