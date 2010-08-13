From: Steve Dickson <SteveD@redhat.com>
Subject: Re: numeric UIDs
Date: Fri, 13 Aug 2010 10:43:06 -0400
Message-ID: <4C6559FA.5070809@RedHat.com>
References: <201008030401.33552.dreck@vmsd.ath.cx>	<20100803164318.GB13896@merit.edu>	<20100803192216.GC31579@fieldses.org>	<DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>	<20100803215704.GA15494@merit.edu>	<1280873719.14520.17.camel@heimdal.trondhjem.org>	<20100803222337.GA9752@fieldses.org>	<1280874675.14520.23.camel@heimdal.trondhjem.org>	<20100803224245.GB9752@fieldses.org>	<1280887336.24669.23.camel@heimdal.trondhjem.org>	<20100805153421.GD27141@fieldses.org> <20100812092232.344314b2@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com,
	linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761687Ab0HMOnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 10:43:22 -0400
In-Reply-To: <20100812092232.344314b2@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/11/2010 07:22 PM, Neil Brown wrote:
> 
> I agree.  And surely it can all be solved in idmapd.
> 
> On the server, tell idmapd to map all users to "NUMERIC_USER:%d" and all
> groups to "NUMERIC_GROUP:%d" (or whatever) for some given clients (i.e. stop
> ignoring the 'authentication name'.  And of course map those names back to
> numbers.
> 
> I don't know if the client can easily differentiate based on which server it
> is talking to, but there is probably less need there (and maybe it can
> anyway).
> 
> It shouldn't take more that half an hour to hack something into
> idmapd.c:nfsdcb() for the server side and nfscb for the client side - or
> for a quicker hack, just go directly to imconv and ignore the client name on
> the server.  (all this in nfs-utils of course).
I took a look... and you are right it would not be that difficult to
hack something up... but would this only be a Linux to Linux thing? 
Or am I missing something?

steved.
