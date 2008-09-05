From: Olaf Kirch <okir@suse.de>
Subject: Re: RESTRICTED_STATD
Date: Fri, 5 Sep 2008 08:56:43 +0200
Message-ID: <200809050856.43464.okir@suse.de>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com> <0B107F2C-ED5A-4098-B59D-FF24CEA2C44B@oracle.com> <18624.35551.98462.115701@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Steve Dickson <steved@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:55839 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbYIEG4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2008 02:56:51 -0400
In-Reply-To: <18624.35551.98462.115701-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday 05 September 2008 03:26:55 Neil Brown wrote:
> I don't know what the Open Group standards say.  My vague memory is

In essence, "use the mon_name, Luke":

  When an NSM receives an SM_NOTIFY call from remote NSM, it must
  search the notify list for the host specified in the SM_NOTIFY call,
  if it is found the RPC specified in "mon_id.my_id" is made.

> "not very much" but I could be wrong.  However I think that "always
> use the mon_name" doesn't actually work in practice, so it doesn't
> really matter if it is a standard or not.

It works as long as the client uses the same name in its lockd
calls (as nlm_host) and in its statd calls. And actually the IP
address is more volatile than the host name.

The are exceptions such as clustered environments, where services move
around along with their IPs. In these cases the IP address will be
constant, but the hostname may change. But that's a relatively rare
configuration, and I think I even added a switch to sm_notify at
some point to help people who use this.

The problem that always existed was lack of security. Anyone can fake
a SM_NOTIFY call, which in essence will drop all locks held by the
spoofed client. That's what I meant when I wrote in my previous email
"Comparing the mon_name and the the result of the DNS reverse
lookup is additional paranoia, and should be configurable."

The primary match when handling SM_NOTIFY should be based on the mon_id.
Comparison of DNS names are an additional paranoia check.

> The cynic in me wonders if this is just so they can tick the box, or
> if there is a real use case that demands it.  Hopefully it is the
> latter.  :-)

I still think we will have IPv6 one day. It's kind of inevitable -
but as long as we don't support it fully, people won't start
using it seriously. And the whole RPC area is one of the major
road blocks in ipv6 adoption in the Linux world.

Olaf
-- 
 And mention in the Fitz incident that DCOP is no ego shooter!
                                --micha istinie, 2001
