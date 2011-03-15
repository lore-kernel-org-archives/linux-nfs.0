From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 17/17] net,act_police,rcu: remove rcu_barrier()
Date: Tue, 15 Mar 2011 12:04:12 +0100
Message-ID: <1300187052.10062.12.camel@edumazet-laptop>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F3B62.6000005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
        linux-decnet-user@lists.sourceforge.net,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-sctp@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
        "Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Ingo Molnar <mingo@elte.hu>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Sridhar Samudrala <sri@us.ibm.com>,
        Vlad Yasevich <vladislav.yasevich@hp.com>,
        Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
        "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Johannes Berg <johannes@sipsolutions.net>,
        Jens Axboe <axboe@kernel.dk>, linux-nfs@vger.kernel.org,
        Jiri Pirko <jpirko@redhat.com>,
        Hideaki YOSHIFU
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <containers-bounces@lists.linux-foundation.org>
In-Reply-To: <4D7F3B62.6000005@cn.fujitsu.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Sender: containers-bounces@lists.linux-foundation.org
Errors-To: containers-bounces@lists.linux-foundation.org
List-ID: <linux-nfs.vger.kernel.org>

TGUgbWFyZGkgMTUgbWFycyAyMDExIMOgIDE4OjExICswODAwLCBMYWkgSmlhbmdzaGFuIGEgw6lj
cml0IDoKPiAKPiBUaGVyZSBpcyBubyBjYWxsYmFjayBvZiB0aGlzIG1vZHVsZSBtYXliZSBxdWV1
ZWQKPiBzaW5jZSB3ZSB1c2Uga2ZyZWVfcmN1KCksIHdlIGNhbiBzYWZlbHkgcmVtb3ZlIHRoZSBy
Y3VfYmFycmllcigpLgo+IAo+IFNpZ25lZC1vZmYtYnk6IExhaSBKaWFuZ3NoYW4gPGxhaWpzQGNu
LmZ1aml0c3UuY29tPgo+IC0tLQo+ICBuZXQvc2NoZWQvYWN0X3BvbGljZS5jIHwgICAgMSAtCj4g
IDEgZmlsZXMgY2hhbmdlZCwgMCBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQo+IAo+IGRp
ZmYgLS1naXQgYS9uZXQvc2NoZWQvYWN0X3BvbGljZS5jIGIvbmV0L3NjaGVkL2FjdF9wb2xpY2Uu
Ywo+IGluZGV4IDA4M2IwOTEuLjIyZTNmOWIgMTAwNjQ0Cj4gLS0tIGEvbmV0L3NjaGVkL2FjdF9w
b2xpY2UuYwo+ICsrKyBiL25ldC9zY2hlZC9hY3RfcG9saWNlLmMKPiBAQCAtMzk3LDcgKzM5Nyw2
IEBAIHN0YXRpYyB2b2lkIF9fZXhpdAo+ICBwb2xpY2VfY2xlYW51cF9tb2R1bGUodm9pZCkKPiAg
ewo+ICAJdGNmX3VucmVnaXN0ZXJfYWN0aW9uKCZhY3RfcG9saWNlX29wcyk7Cj4gLQlyY3VfYmFy
cmllcigpOyAvKiBXYWl0IGZvciBjb21wbGV0aW9uIG9mIGNhbGxfcmN1KCkncyAodGNmX3BvbGlj
ZV9mcmVlX3JjdSkgKi8KPiAgfQo+ICAKPiAgbW9kdWxlX2luaXQocG9saWNlX2luaXRfbW9kdWxl
KTsKCgpXaHkgaXMgaXQgYSBzZXBhcmF0ZSBwYXRjaCwgYW5kIG5vdCBpbmNsdWRlZCBpbiBwYXRj
aCA1LzE3ID8KCgoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5k
YXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0
aW5mby9jb250YWluZXJz
