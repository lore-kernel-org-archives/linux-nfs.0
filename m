From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Linux NFS-HOWTO - improvement to Troubleshooting permission denied
Date: Mon, 25 Aug 2008 12:55:52 -0400
Message-ID: <91E7D24F-6BAE-4258-8970-32EDD2691F9F@oracle.com>
References: <87skstbl7j.fsf@jondo.cante.net> <76bd70e30808250841v4e73c576qc1e68c85d88bb989@mail.gmail.com> <20080825155503.GH30871@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jari Aalto <jari.aalto-w6EBCRcXQ4deoWH0uzbU5w@public.gmane.org>,
	NFS HOWTO author <smithere@gmail.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	chip@users.sourceforge.net, jweber@users.sourceforge.net,
	marcmerlin@users.sourceforge.net, Neil Brown <neilb@suse.de>,
	Steve Dickson <SteveD@redhat.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:55159 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869AbYHYQ6q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 12:58:46 -0400
In-Reply-To: <20080825155503.GH30871@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some CC's corrected.

On Aug 25, 2008, at Aug 25, 2008, 11:55 AM, J. Bruce Fields wrote:
> On Mon, Aug 25, 2008 at 11:41:02AM -0400, Chuck Lever wrote:
>> Hi Jari-
>>
>> On Mon, Aug 25, 2008 at 3:36 AM, Jari Aalto <jari.aalto-w6EBCRcXQ4deoWH0uzbU5w@public.gmane.org>  
>> wrote:
>>>
>>> Thank you for the NFS howto (last modified 2006). Please add further
>>> diagnostics to section:
>>>
>>>       => "I do not have permission to access files on the mounted  
>>> volume"
>>>       http://nfs.sourceforge.net/nfs-howto/ar01s07.html#pemission_issues
>>>
>>> The error condition "Permission denied" also happens in certain NFS
>>> (client/server) combinations and the workaround is to add additional
>>> mount parameter at client:
>>>
>>>       sec=sys
>>>
>>> Please add this to the "#pemission_issues" (tag the word seems to  
>>> have a
>>> small typo).
>>
>> This is a known bug in nfs-utils 1.1.3 when used with older client
>> kernels that do not support text-based mounts.
>>
>> Seems like an esoteric (ie not widespread) problem, but I could  
>> easily
>> be wrong about that.
>
> People should be able to upgrade nfs-utils without upgrading their
> kernel!

Of course.  But Bugs Happen.  I'm not implying that nfs-utils 1.1.3  
requires a kernel upgrade, but merely describing the conditions where  
the issue appears.

In fact, you may recall a recent and rather protracted e-mail  
conversation where we determined that the text-based NFS mount  
implementation is not working correctly in this case either.

> The referenced debian bug report:
>
> 	http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=492970
>
> claims the first bad commit is a server-side commit that itself  
> seems to
> claim to work around a problem?  ("For mountd, it does not advertise
> AUTH_NULL anymore. This is necessary to avoid backward compatibility
> issue. If AUTH_NULL appears in the list, either the new or the old
> client will choose that over AUTH_SYS.")
>
> Did we ever find the actual root cause?

The bad commit does not live up to the comments it introduced, which  
claim that the legacy mount command will skip AUTH_NULL as a default  
if it receives it in the auth flavor list from mountd.  I haven't  
verified this, but otherwise, yes, we have an RCA.

I copied the patch author of record, bcwong-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, on the recent  
discussion, but we haven't heard any response.  I think we will need  
to fix this ourselves.  IMO the proper fix is to eliminate the  
possibility that the client will ever use AUTH_NULL unless "sec=null"  
is explicitly specified on the mount command line, then to get nfs- 
utils 1.1.4 posted with this fix.

If I may also observe: the bad commit attempts to change both server- 
side and client-side behavior in one go.  Hindsight suggests the  
changes to nfsmount.c and mountd.c should have occurred in two  
separate commits so that automated bisection and surgical reversion  
are possible.

This reminds us again that we have an exponentially expanding test  
matrix for nfs-utils, especially considering the backwards- 
compatibility requirements.  I would love to see significant test  
resources committed in this area.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
