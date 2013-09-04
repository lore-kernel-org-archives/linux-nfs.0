Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32857 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab3IDWSc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 18:18:32 -0400
Date: Wed, 4 Sep 2013 18:18:29 -0400
From: "<bfields@fieldses.org>" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: SECINFO* can use integrity protected flavors
Message-ID: <20130904221829.GH10232@fieldses.org>
References: <1378232772-4066-1-git-send-email-dros@netapp.com>
 <FA9EEDBA-44B6-4C4D-B981-D5C933A161C2@oracle.com>
 <CCE068C5-3699-4258-A4ED-552E44B39173@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CCE068C5-3699-4258-A4ED-552E44B39173@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 03, 2013 at 07:11:57PM +0000, Adamson, Dros wrote:
> 
> On Sep 3, 2013, at 2:48 PM, Chuck Lever <chuck.lever@oracle.com>
>  wrote:
> 
> > 
> > On Sep 3, 2013, at 2:26 PM, Weston Andros Adamson <dros@netapp.com> wrote:
> > 
> >> SECINFO and SECINFO_NONAME should be able to use integrity protected auth
> >> flavors even if the export wasn't explicitly configured to use them.
> >> 
> >> An example is a sec=sys export - upstream linux clients will attempt to use
> >> krb5i for EXCHANGE_ID, CREATE_SESSION, DESTROY_SESSION, etc.  If this is
> >> successful, the client will try to use the same auth flavor for SECINFO
> >> as described in the Security Considerations sections of rfc3530 and rfc5661.
> > 
> > The reason krb5i can work for lease management operations is because those operations are not connected to any particular export, so typically they are not controlled directly by export security settings.
> > 
> > But I'm not sure all server implementations will allow a SECINFO on an FSID using a flavor not allowed by the FSID's export options.  SECINFO is definitely connected to a particular FSID, unlike lease management operations.
> 
> I understand how these operations are different from SECINFO, but the spec is pretty clear that krb5i/p should be used if at all possible.
> 
> > 
> > Given FreeBSD's implementation choices wrt lease management security flavors, that would be the first server I'd check.
> > 
> >> This patch adds a nfsd4_op_flag to describe operations that may use these
> >> auth flavors to get around nfsd_access() checks. This should be useful in
> >> future implementations of SP4_MACH_CRED (nfsd_permission still needs to be
> >> handled).
> >> 
> >> This patch also stops SECINFO* from returning NFS4ERR_WRONGSEC which is
> >> not allowed by either rfc3530 (not in list of allowed errors) or rfc6551
> > 
> > 5661
> 
> Heh, good catch!
> 
> > 
> >> (section 2.6.3.1.1.5 says it MUST NOT).
> > 
> > That sounds inconsistent with the Security Considerations recommendation.
> 
> How so? Just because we don't know what error to return if the server doesn't support the recommendation to use integrity protection for SECINFO?
> 
> > 
> > Recommending that a client use integrity protection means servers MUST support it, or the client has to be prepared to retry it with some other flavor, and the server MUST have a way to ask for a retry (ie in that case, wouldn't WRONGSEC be the correct way to make such a request?).
> 
> So, I'm preparing to post a client-side patch that retries (with filesystem's rpc_client) if the server returns NFS4ERR_WRONGSEC as Trond doesn't want the client to be broken against deployed linux servers, but this is a good question - what error should a server return in this case?
> 
> > 
> > Is there anything more in these RFCs that would require a server to support SECINFO via krb5i?
> > 
> > Thus I wonder if clients can depend on a krb5i SECINFO on a sec=sys FSID working everywhere.
> 
> Sections 17 of rfc3530bis and 21 of rfc 5661 clearly state that it's RECOMMENDED to use integrity protection for SECINFO and SECINFO_NONAME, so I think we should try, but your point remains - what error should a server return if the server doesn't support this?

I'm confused--we should just allow SECINFO/SECINFO_NO_NAME in these
cases and then we don't have to decide, right?

--b.
