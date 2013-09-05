Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:26803 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378Ab3IEPDw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Sep 2013 11:03:52 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "<bfields@fieldses.org>" <bfields@fieldses.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: SECINFO* can use integrity protected flavors
Date: Thu, 5 Sep 2013 15:03:49 +0000
Message-ID: <02B0E136-5FEC-4C29-9A97-B3B7D328B6BA@netapp.com>
References: <1378232772-4066-1-git-send-email-dros@netapp.com>
 <FA9EEDBA-44B6-4C4D-B981-D5C933A161C2@oracle.com>
 <CCE068C5-3699-4258-A4ED-552E44B39173@netapp.com>
 <20130904221829.GH10232@fieldses.org>
 <59BD1498-C587-4591-98C9-C65EC375F31D@oracle.com>
In-Reply-To: <59BD1498-C587-4591-98C9-C65EC375F31D@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 5, 2013, at 10:07 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Sep 4, 2013, at 6:18 PM, bfields@fieldses.org wrote:
> 
>> On Tue, Sep 03, 2013 at 07:11:57PM +0000, Adamson, Dros wrote:
>>> 
>>> On Sep 3, 2013, at 2:48 PM, Chuck Lever <chuck.lever@oracle.com>
>>> wrote:
>>> 
>>>> 
>>>> On Sep 3, 2013, at 2:26 PM, Weston Andros Adamson <dros@netapp.com> wrote:
>>>> 
>>>>> SECINFO and SECINFO_NONAME should be able to use integrity protected auth
>>>>> flavors even if the export wasn't explicitly configured to use them.
>>>>> 
>>>>> An example is a sec=sys export - upstream linux clients will attempt to use
>>>>> krb5i for EXCHANGE_ID, CREATE_SESSION, DESTROY_SESSION, etc.  If this is
>>>>> successful, the client will try to use the same auth flavor for SECINFO
>>>>> as described in the Security Considerations sections of rfc3530 and rfc5661.
>>>> 
>>>> The reason krb5i can work for lease management operations is because those operations are not connected to any particular export, so typically they are not controlled directly by export security settings.
>>>> 
>>>> But I'm not sure all server implementations will allow a SECINFO on an FSID using a flavor not allowed by the FSID's export options.  SECINFO is definitely connected to a particular FSID, unlike lease management operations.
>>> 
>>> I understand how these operations are different from SECINFO, but the spec is pretty clear that krb5i/p should be used if at all possible.
>>> 
>>>> 
>>>> Given FreeBSD's implementation choices wrt lease management security flavors, that would be the first server I'd check.
>>>> 
>>>>> This patch adds a nfsd4_op_flag to describe operations that may use these
>>>>> auth flavors to get around nfsd_access() checks. This should be useful in
>>>>> future implementations of SP4_MACH_CRED (nfsd_permission still needs to be
>>>>> handled).
>>>>> 
>>>>> This patch also stops SECINFO* from returning NFS4ERR_WRONGSEC which is
>>>>> not allowed by either rfc3530 (not in list of allowed errors) or rfc6551
>>>> 
>>>> 5661
>>> 
>>> Heh, good catch!
>>> 
>>>> 
>>>>> (section 2.6.3.1.1.5 says it MUST NOT).
>>>> 
>>>> That sounds inconsistent with the Security Considerations recommendation.
>>> 
>>> How so? Just because we don't know what error to return if the server doesn't support the recommendation to use integrity protection for SECINFO?
>>> 
>>>> 
>>>> Recommending that a client use integrity protection means servers MUST support it, or the client has to be prepared to retry it with some other flavor, and the server MUST have a way to ask for a retry (ie in that case, wouldn't WRONGSEC be the correct way to make such a request?).
>>> 
>>> So, I'm preparing to post a client-side patch that retries (with filesystem's rpc_client) if the server returns NFS4ERR_WRONGSEC as Trond doesn't want the client to be broken against deployed linux servers, but this is a good question - what error should a server return in this case?
>>> 
>>>> 
>>>> Is there anything more in these RFCs that would require a server to support SECINFO via krb5i?
>>>> 
>>>> Thus I wonder if clients can depend on a krb5i SECINFO on a sec=sys FSID working everywhere.
>>> 
>>> Sections 17 of rfc3530bis and 21 of rfc 5661 clearly state that it's RECOMMENDED to use integrity protection for SECINFO and SECINFO_NONAME, so I think we should try, but your point remains - what error should a server return if the server doesn't support this?
>> 
>> I'm confused--we should just allow SECINFO/SECINFO_NO_NAME in these
>> cases and then we don't have to decide, right?
> 
> I've finally read the relevant sections of the RFCs (doi!).  RFC 5661 section 2.6.3.1.1.4 and following discuss SECINFO/SECINFO_NO_NAME and NFS4ERR_WRONGSEC in some detail.
> 
> The way I read this, a server MUST NOT return NFS4ERR_WRONGSEC on any SECINFO or SECINFO_NO_NAME request, and MUST NOT return NFS4ERR_WRONGSEC on a PUTFH if the subsequent operation is SECINFO or SECINFO_NO_NAME.
> 
> Section 2.6.3.1.1.5 explicitly says "In theory, there is no connection between the security flavor used by SECINFO or SECINFO_NO_NAME and those supported by the security policy."  Despite the fact that both of these operations take a FH, and thus would be otherwise subject to the security policy in place for the containing FSID, they should be permitted under all security flavors a server supports.
> 
> If the server truly does not support the specified security flavor, an RPC-level error occurs, as Trond points out, and as the first paragraph of section 2.6.3.1.1.5 says.  This is an indication to the client that it should retry the SECINFO with another flavor.
> 
> RFC 3530bis does not state a similar strong requirement.  However, NFS4ERR_WRONGSEC is not listed in the valid status codes for the SECINFO operation, so we might assume that a client should expect similar behavior for NFSv4.0.

Well put - thanks Chuck!

> 
> For the server, "we should just allow SECINFO/SECINFO_NO_NAME in these cases".  Perhaps there should be no security check at all -- the RPC layer should already cover the totally unsupported flavor case.  The only detail is ignoring security policy conflicts in a preceding PUTFH in the same compound.
> 

So should I refactor this patch so that it doesn't "allow integrity" for flagged operations and instead simply skips access checks?

> I think the main difficulty now is that some versions of the Linux server do not behave this way.

Indeed - thats why my recent client patches will handle WRONGSEC on SECINFO* - the SECINFO patch has been accepted by Trond, but the SECINFO_NO_NAME patch is still under discussion.

-dros

> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 

