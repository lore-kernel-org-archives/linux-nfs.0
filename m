Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4409 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750800AbdKJHT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Nov 2017 02:19:29 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 0/2] race of lockd/nfsd inetaddr notifiers vs pointers change
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Scott Mayhew <smayhew@redhat.com>
References: <20171031172926.aryzmxz6nvsqlg56@tonberry.usersys.redhat.com>
Message-ID: <4c4bb24c-a1e2-16e9-717e-67bf432b990c@virtuozzo.com>
Date: Fri, 10 Nov 2017 10:19:16 +0300
MIME-Version: 1.0
In-Reply-To: <20171031172926.aryzmxz6nvsqlg56@tonberry.usersys.redhat.com>
Content-Type: multipart/mixed;
 boundary="------------CBBD556224E4E4C4276EED5C"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------CBBD556224E4E4C4276EED5C
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

lockd and nfsd inet[6]addr notifiers use pointer that can be changed during execution.

lockd_inetaddr_event()
...
        if (nlmsvc_rqst) {  
		... 
                svc_age_temp_xprts_now(nlmsvc_rqst->rq_server, (struct sockaddr *)&sin);
        }

Usually access to  nlmsvc_rqst is protected by nlmsvc_mutex 
However lockd_inet[6]addr_event does not take the mutex,
therefore nlmsvc_rqst can be changed during execution.

As result "if (nlmsvc_rqst)" can be passed,
then another thread frees the memory or zeroes this pointer,
and then svc_age_temp_xprts_now crash the host on access to already freed memory.

Moreover on initialization nlmsvc_rqst can be temporally set to ERR_PTR.

NFSD have similar issue, its reproducer is below

1) start nfsd on host 
# service nfs start

2) create separate net and mount namespaces:
# unshare -m -n  ; mount -t nfsd nfsd /proc/fs/nfsd

3) execute screen (we need 2 consoles with newly created namespaces)
4) on first console:
# ifconfig lo up
# while : ; do ip a a  1.2.3.4/32 dev lo ; do ip a d 1.2.3.4/32 dev lo ; done

5) on second console:
# while : ; do echo 1 > /proc/fs/nfsd/threads ; sleep 1 ; echo 0 > /proc/fs/nfsd/threads ; sleep 1 ; done

Result: crash inside nfsd_inteddr_event(), see demsg in attachment.

We cannot add mutexes into notifiers because inet6addr notifiers should be atomic.

To fix the problem I use atomic counter and waitqueue:
counter allows notifier to access the pointer,
waitqueue allows to delay stop of service until notifier is in use.

Vasily Averin (2):
  race of lockd inetaddr notifiers vs nlmsvc_rqst change
  race of nfsd inetaddr notifiers vs nn->nfsd_serv change

 fs/lockd/svc.c   | 16 ++++++++++++++--
 fs/nfsd/netns.h  |  3 +++
 fs/nfsd/nfsctl.c |  3 +++
 fs/nfsd/nfssvc.c | 14 +++++++++++---
 4 files changed, 31 insertions(+), 5 deletions(-)

-- 
2.7.4


--------------CBBD556224E4E4C4276EED5C
Content-Type: text/plain; charset=UTF-8;
 name="ml2.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="ml2.txt"

WyAgNjA0LjI5NDA1NV0gbmZzZF9pbmV0YWRkcl9ldmVudDogcmVtb3ZlZCAxLjIuMy40Clsg
IDYwNC4yOTQwNjBdIG5mc2Q6IGxhc3Qgc2VydmVyIGhhcyBleGl0ZWQsIGZsdXNoaW5nIGV4
cG9ydCBjYWNoZQpbICA2MDQuMjk1OTIyXSBCVUc6IHVuYWJsZSB0byBoYW5kbGUga2VybmVs
IE5VTEwgcG9pbnRlciBkZXJlZmVyZW5jZSBhdCAwMDAwMDAwMDAwMDAwMDEwClsgIDYwNC4y
OTYxODldIElQOiBfcmF3X3NwaW5fbG9ja19iaCsweDFiLzB4MzAKWyAgNjA0LjI5NjE4OV0g
UEdEIDVhNTk2MDY3IFA0RCA1YTU5NjA2NyBQVUQgMzA1MmUwNjcgUE1EIDAgClsgIDYwNC4y
OTYxODldIE9vcHM6IDAwMDIgWyMxXSBTTVAKWyAgNjA0LjI5ODg0NF0gTW9kdWxlcyBsaW5r
ZWQgaW46IGJpbmZtdF9taXNjIG5mc2QgYXV0aF9ycGNnc3MgbmZzX2FjbCBsb2NrZChFKSBn
cmFjZSBpcDZ0X3JwZmlsdGVyIGlwNnRfUkVKRUNUIG5mX3JlamVjdF9pcHY2IHh0X2Nvbm50
cmFjayBpcF9zZXQgbmZuZXRsaW5rIGVidGFibGVfbmF0IGVidGFibGVfYnJvdXRlIGJyaWRn
ZSBzdHAgbGxjIGlwNnRhYmxlX25hdCBuZl9jb25udHJhY2tfaXB2NiBuZl9kZWZyYWdfaXB2
NiBuZl9uYXRfaXB2NiBpcDZ0YWJsZV9tYW5nbGUgaXA2dGFibGVfcmF3IGlwNnRhYmxlX3Nl
Y3VyaXR5IGlwdGFibGVfbmF0IG5mX2Nvbm50cmFja19pcHY0IG5mX2RlZnJhZ19pcHY0IG5m
X25hdF9pcHY0IG5mX25hdCBuZl9jb25udHJhY2sgaXB0YWJsZV9tYW5nbGUgaXB0YWJsZV9y
YXcgaXB0YWJsZV9zZWN1cml0eSBlYnRhYmxlX2ZpbHRlciBlYnRhYmxlcyBpcDZ0YWJsZV9m
aWx0ZXIgaXA2X3RhYmxlcyBzdW5ycGMgam95ZGV2IHBwZGV2IHZpcnRpb19iYWxsb29uIGNy
Y3QxMGRpZl9wY2xtdWwgY3JjMzJfcGNsbXVsIGdoYXNoX2NsbXVsbmlfaW50ZWwgcHZwYW5p
YyBwYXJwb3J0X3BjIHBjc3BrciBwYXJwb3J0IGkyY19waWl4NCB4ZnMgbGliY3JjMzJjIHZp
cnRpb19jb25zb2xlIHZpcnRpb19uZXQgdmlydGlvX3Njc2kgYm9jaHNfZHJtIGRybV9rbXNf
aGVscGVyIGNyYzMyY19pbnRlbCB0dG0gZHJtIHNlcmlvX3JhdyB2aXJ0aW9fcGNpIHZpcnRp
b19yaW5nIHZpcnRpbyBhdGFfZ2VuZXJpYyBwYXRhX2FjcGkgZmxvcHB5ClsgIDYwNC4zMDIx
ODhdIENQVTogNiBQSUQ6IDQzMTAgQ29tbTogaXAgVGFpbnRlZDogRyAgICAgICAgICAgIEUg
ICA0LjE0LjAtcmM2KyAjMgpbICA2MDQuMzAyMTg4XSBIYXJkd2FyZSBuYW1lOiBWaXJ0dW96
em8gS1ZNLCBCSU9TIDEuOS4xLTUuMy4yLnZ6Ny43IDA0LzAxLzIwMTQKWyAgNjA0LjMwNTEx
N10gdGFzazogZmZmZjhlOWVkYTUxMjg0MCB0YXNrLnN0YWNrOiBmZmZmYjEwNzRmMjg4MDAw
ClsgIDYwNC4zMDUxNjZdIFJJUDogMDAxMDpfcmF3X3NwaW5fbG9ja19iaCsweDFiLzB4MzAK
WyAgNjA0LjMwNjAzNF0gUlNQOiAwMDE4OmZmZmZiMTA3NGYyOGI5NTAgRUZMQUdTOiAwMDAx
MDI0NgpbICA2MDQuMzA2MDM0XSBSQVg6IDAwMDAwMDAwMDAwMDAwMDAgUkJYOiAwMDAwMDAw
MDAwMDAwMDM4IFJDWDogMDAwMDAwMDAwMDAwMDAwMApbICA2MDQuMzA3MDM0XSBSRFg6IDAw
MDAwMDAwMDAwMDAwMDEgUlNJOiBmZmZmYjEwNzRmMjhiOWQwIFJESTogMDAwMDAwMDAwMDAw
MDAxMApbICA2MDQuMzA3MDM0XSBSQlA6IGZmZmZiMTA3NGYyOGI5NTAgUjA4OiAwMDAwMDAw
MDAwMDE5MGJkIFIwOTogMDAwMDAwMDAwMDAwMDAwMApbICA2MDQuMzA3MDM0XSBSMTA6IDAw
MDAwMDAwZmYwMDAwMDAgUjExOiAwMDAwMDAwMGZmZmZmZmZmIFIxMjogZmZmZmIxMDc0ZjI4
Yjk3OApbICA2MDQuMzA3MDM0XSBSMTM6IGZmZmZiMTA3NGYyOGI5ZDAgUjE0OiBmZmZmOGU5
ZWVmY2Q4YWU4IFIxNTogMDAwMDAwMDAwMDAwMDAwMApbICA2MDQuMzA3MDM0XSBGUzogIDAw
MDA3ZjE2ZjVlNzIwYzAoMDAwMCkgR1M6ZmZmZjhlOWVmZmQ4MDAwMCgwMDAwKSBrbmxHUzow
MDAwMDAwMDAwMDAwMDAwClsgIDYwNC4zMTMyMzZdIENTOiAgMDAxMCBEUzogMDAwMCBFUzog
MDAwMCBDUjA6IDAwMDAwMDAwODAwNTAwMzMKWyAgNjA0LjMxMzIzNl0gQ1IyOiAwMDAwMDAw
MDAwMDAwMDEwIENSMzogMDAwMDAwMDA1YTY5NTAwNSBDUjQ6IDAwMDAwMDAwMDAxNjA2ZTAK
WyAgNjA0LjMxMzIzNl0gQ2FsbCBUcmFjZToKWyAgNjA0LjMxMzIzNl0gIHN2Y19hZ2VfdGVt
cF94cHJ0c19ub3crMHg0Yi8weDIwMCBbc3VucnBjXQpbICA2MDQuMzE1MTczXSAgbmZzZF9p
bmV0YWRkcl9ldmVudCsweDg3LzB4YjAgW25mc2RdClsgIDYwNC4zMTUxNzNdICBub3RpZmll
cl9jYWxsX2NoYWluKzB4NGEvMHg3MApbICA2MDQuMzE1MTczXSAgYmxvY2tpbmdfbm90aWZp
ZXJfY2FsbF9jaGFpbisweDQzLzB4NjAKWyAgNjA0LjMxNTE3M10gIF9faW5ldF9kZWxfaWZh
KzB4MTZiLzB4MmMwClsgIDYwNC4zMTUxNzNdICBpbmV0X3J0bV9kZWxhZGRyKzB4MTI5LzB4
MWMwClsgIDYwNC4zMTUxNzNdICBydG5ldGxpbmtfcmN2X21zZysweDFmOS8weDI4MApbICA2
MDQuMzE1MTczXSAgPyBydG5sX2NhbGNpdC5pc3JhLjI0KzB4MTEwLzB4MTEwClsgIDYwNC4z
MTUxNzNdICBuZXRsaW5rX3Jjdl9za2IrMHg5MS8weDEzMApbICA2MDQuMzIyODUwXSAgcnRu
ZXRsaW5rX3JjdisweDE1LzB4MjAKWyAgNjA0LjMyMjg1MF0gIG5ldGxpbmtfdW5pY2FzdCsw
eDE4ZS8weDIyMApbICA2MDQuMzIyODUwXSAgbmV0bGlua19zZW5kbXNnKzB4MmM1LzB4M2Mw
ClsgIDYwNC4zMjUxMTRdICBzb2NrX3NlbmRtc2crMHgzOC8weDUwClsgIDYwNC4zMjUxNTBd
ICBfX19zeXNfc2VuZG1zZysweDI5YS8weDJmMApbICA2MDQuMzI1MTUwXSAgPyBscnVfY2Fj
aGVfYWRkKzB4M2EvMHg4MApbICA2MDQuMzI1MTUwXSAgPyBscnVfY2FjaGVfYWRkX2FjdGl2
ZV9vcl91bmV2aWN0YWJsZSsweDRjLzB4ZjAKWyAgNjA0LjMyNTE1MF0gID8gX19oYW5kbGVf
bW1fZmF1bHQrMHg5YmUvMHgxMWEwClsgIDYwNC4zMjUxNTBdICA/IGhhbmRsZV9tbV9mYXVs
dCsweGIxLzB4MjAwClsgIDYwNC4zMjUxNTBdICBfX3N5c19zZW5kbXNnKzB4NTQvMHg5MApb
ICA2MDQuMzI1MTUwXSAgPyBfX3N5c19zZW5kbXNnKzB4NTQvMHg5MApbICA2MDQuMzI1MTUw
XSAgU3lTX3NlbmRtc2crMHgxMi8weDIwClsgIDYwNC4zMjUxNTBdICBlbnRyeV9TWVNDQUxM
XzY0X2Zhc3RwYXRoKzB4MWEvMHhhNQpbICA2MDQuMzI1MTUwXSBSSVA6IDAwMzM6MHg3ZjE2
ZjU1NzllNTcKWyAgNjA0LjMzMTY2NV0gUlNQOiAwMDJiOjAwMDA3ZmZmYTM4YjQ2MjggRUZM
QUdTOiAwMDAwMDI0NiBPUklHX1JBWDogMDAwMDAwMDAwMDAwMDAyZQpbICA2MDQuMzMyMzY2
XSBSQVg6IGZmZmZmZmZmZmZmZmZmZGEgUkJYOiAwMDAwMDAwMDAwNjcxNGMwIFJDWDogMDAw
MDdmMTZmNTU3OWU1NwpbICA2MDQuMzMyOTIwXSBSRFg6IDAwMDAwMDAwMDAwMDAwMDAgUlNJ
OiAwMDAwN2ZmZmEzOGI0NjcwIFJESTogMDAwMDAwMDAwMDAwMDAwMwpbICA2MDQuMzMzMTkx
XSBSQlA6IDAwMDA3ZmZmYTM4YmNhZjAgUjA4OiAwMDAwMDAwMDAwMDAwMDAxIFIwOTogZmVm
ZWZlZmY3NzY4NmQ3NApbICA2MDQuMzMzMTkxXSBSMTA6IDAwMDAwMDAwMDAwMDAwMDYgUjEx
OiAwMDAwMDAwMDAwMDAwMjQ2IFIxMjogMDAwMDdmZmZhMzhiYzgwMApbICA2MDQuMzMzMTkx
XSBSMTM6IDAwMDAwMDAwMDAwMDAwMDAgUjE0OiAwMDAwN2ZmZmEzOGJjN2EwIFIxNTogMDAw
MDdmZmZhMzhiYzdhOApbICA2MDQuMzMzMTkxXSBDb2RlOiAwMCA1ZCBjMyAzMSBjMCA1ZCBj
MyA2NiAwZiAxZiA4NCAwMCAwMCAwMCAwMCAwMCAwZiAxZiA0NCAwMCAwMCA1NSA2NSA4MSAw
NSBhZiA0NyA3NiA2NCAwMCAwMiAwMCAwMCA0OCA4OSBlNSAzMSBjMCBiYSAwMSAwMCAwMCAw
MCA8ZjA+IDBmIGIxIDE3IDg1IGMwIDc1IDAyIDVkIGMzIDg5IGM2IGU4IGQ0IGFjIDg0IGZm
IDVkIGMzIDY2IDkwIApbICA2MDQuMzM1MTAyXSBSSVA6IF9yYXdfc3Bpbl9sb2NrX2JoKzB4
MWIvMHgzMCBSU1A6IGZmZmZiMTA3NGYyOGI5NTAKWyAgNjA0LjMzNTEwMl0gQ1IyOiAwMDAw
MDAwMDAwMDAwMDEwCg==
--------------CBBD556224E4E4C4276EED5C--
