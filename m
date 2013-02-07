Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:40866 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891Ab3BGRMe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 12:12:34 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] SUNRPC: Refactor nfsd4_do_encode_secinfo()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <436D6F2C-E520-4375-A518-2E55031E70F7@oracle.com>
Date: Thu, 7 Feb 2013 12:12:24 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A98AFAD6-2E43-4646-8287-8C023DFA65DF@oracle.com>
References: <20130201220308.13518.82164.stgit@seurat.1015granger.net> <20130207150213.GC3222@fieldses.org> <87316F41-4E5E-473C-A372-0AFC6721A355@oracle.com> <20130207162308.GI3222@fieldses.org> <F0DAA0C6-DBA2-457B-8C68-13A2BC3CB4AC@oracle.com> <20130207165509.GM3222@fieldses.org> <436D6F2C-E520-4375-A518-2E55031E70F7@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 7, 2013, at 12:03 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Feb 7, 2013, at 11:55 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Thu, Feb 07, 2013 at 11:26:43AM -0500, Chuck Lever wrote:
>>> 
>>> On Feb 7, 2013, at 11:23 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> 
>>>> On Thu, Feb 07, 2013 at 10:58:25AM -0500, Chuck Lever wrote:
>>>>> 
>>>>> On Feb 7, 2013, at 10:02 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>>> 
>>>>>> On Fri, Feb 01, 2013 at 05:43:44PM -0500, Chuck Lever wrote:
>>>>>>> Clean up.  This matches a similar API for the client side, and
>>>>>>> keeps ULP fingers out the of the GSS mech switch.
>>>>>>> 
>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>> Acked-by: J. Bruce Fields <bfields@redhat.com>
>>>>>>> ---
>>>>>>> 
>>>>>>> Bruce-
>>>>>>> 
>>>>>>> This version of the patch follows the existing logic in
>>>>>>> nfsd4_do_encode_secinfo(): If the RPC layer can't find GSS info
>>>>>>> that matches an export security flavor, it assumes the flavor is
>>>>>>> not a GSS pseudoflavor, and simply puts it on the wire.
>>>>>>> 
>>>>>>> However, if the below XDR encoding logic is given a legitimate GSS
>>>>>>> pseudoflavor but the RPC layer says it does not support that
>>>>>>> pseudoflavor for some reason, then we leak GSS pseudoflavor numbers
>>>>>>> onto the wire.
>>>>>>> 
>>>>>>> I confirmed this happens by blacklisting rpcsec_gss_krb5, then
>>>>>>> attempted a client transition from the pseudo-fs to a Kerberos-only
>>>>>>> share.  The client received a flavor list containing the Kerberos
>>>>>>> pseudoflavor numbers, rather than GSS tuples.
>>>>>>> 
>>>>>>> The encoder logic can check that each pseudoflavor is less than
>>>>>>> MAXFLAVOR before writing it into the buffer, to prevent this.  But
>>>>>>> after "nflavs" is written into the XDR buffer, the encoder can't
>>>>>>> skip writing flavor information into the buffer when it discovers
>>>>>>> the RPC layer doesn't support that flavor.
>>>>>>> 
>>>>>>> Is there some way of writing "nflavs" into the XDR buffer after
>>>>>>> the loop that writes the flavor information is complete?
>>>>>> 
>>>>>> Yes, you can save a pointer and then go back and fill that in--see
>>>>>> encode_fattr for an example.
>>>>> 
>>>>> Thanks, I will submit an additional patch that describes this issue and fixes it.
>>>>> 
>>>>> I asked David Noveck, as one of the authors of RFC 3530, whether an NFS server should return a zero-length flavor list or an error if SECINFO can't find any flavors a client is allowed to use. His opinion was to return NFS4_OK and a zero-length flavor list.
>>>> 
>>>> Fine with me for this code.
>>> 
>>> OK, will go with that.
>>> 
>>>> (In practice though we should probably be warning somewhere (exportfs?)
>>>> if somebody creates an export like that.)
>>> 
>>> The problem can also arise because gssd isn't running or auth_rpcgss.ko or rpcsec_gss_krb5.ko are not loadable for some reason.  In other words, an empty flavor list might also be the result of a transient server misconfiguration.
>> 
>> OK.  Do you think the kernel could help by providing a once-only warning
>> in such a case?  (Or in the case when we're not able to find support for
>> a security flavor set on the export.)
> 
> I've thought a little about that.  There is already a logged warning if a gssd upcall times out.  But it's hard to tell inside the kernel why a module doesn't load.  These all look pretty much the same to the RPC layer:
> 
>   -  module is blacklisted or not installed?
>   -  GSS support wasn't built?
>   -  filesystem corruption?
>   -  export specifies a security flavor the RPC client doesn't recognize?
> 
> I suppose I could add something here, but I wonder about the false alarms.

How about this:

  "Warning: export specifies a security flavor that isn't supported"

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




