Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64933 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879Ab1DBLRl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Apr 2011 07:17:41 -0400
Received: by bwz15 with SMTP id 15so3043940bwz.19
        for <linux-nfs@vger.kernel.org>; Sat, 02 Apr 2011 04:17:39 -0700 (PDT)
Date: Sat, 2 Apr 2011 14:17:34 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: kstrtox: convert net/sunrpc/
Message-ID: <20110402111734.GA19357@p183.telecom.by>
References: <20110331213625.GA3637@p183.telecom.by>
 <2A9AAF9A-727C-4558-883C-8052D1E2EF5A@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2A9AAF9A-727C-4558-883C-8052D1E2EF5A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Apr 01, 2011 at 12:57:41PM -0400, Chuck Lever wrote:
> On Mar 31, 2011, at 5:36 PM, Alexey Dobriyan wrote:
> 
> > * fix a bug in rpc_parse_scope_id() where successfull parsing of
> >  scope ID was an error.
> 
> What was the bad behavior?

rpc_parse_scope_id() always rejected scope ids, because strict_strtoul()
returned 0 on success.

> > --- a/net/sunrpc/addr.c
> > +++ b/net/sunrpc/addr.c
> > @@ -173,15 +173,15 @@ static int rpc_parse_scope_id(const char *buf, const size_t buflen,
> > 	len = (buf + buflen) - delim - 1;
> > 	p = kstrndup(delim + 1, len, GFP_KERNEL);
> > 	if (p) {
> > -		unsigned long scope_id = 0;
> > 		struct net_device *dev;
> > +		u32 scope_id;
> > 
> > 		dev = dev_get_by_name(&init_net, p);
> > 		if (dev != NULL) {
> > 			scope_id = dev->ifindex;
> > 			dev_put(dev);
> > 		} else {
> > -			if (strict_strtoul(p, 10, &scope_id) == 0) {
> > +			if (kstrtou32(p, 10, &scope_id) < 0) {
> > 				kfree(p);
> > 				return 0;
> > 			}
