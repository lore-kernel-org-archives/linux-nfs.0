From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/18] kernel NSM support for IPv6 (take 2)
Date: Wed, 5 Nov 2008 16:50:30 -0500
Message-ID: <20081105215030.GL1455@fieldses.org>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net> <20081105194955.GA1455@fieldses.org> <20081105204517.GC1455@fieldses.org> <61853126-2B02-44C8-B47B-C4CD8618EF0C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46701 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041AbYKEVud (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 16:50:33 -0500
In-Reply-To: <61853126-2B02-44C8-B47B-C4CD8618EF0C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2008 at 04:34:01PM -0500, Chuck Lever wrote:
> On Nov 5, 2008, at 3:45 PM, J. Bruce Fields wrote:
>> On Wed, Nov 05, 2008 at 02:49:55PM -0500, bfields wrote:
>>> By the way, I did some miscellaneous nsm cleanup a few months ago and
>>> never got around to sending it out.  I'll pass that along in a  
>>> moment.
>>
>> For which I meant to send out a cover letter and forgot, sorry!
>
> These look similar to some prototype patches I've played with to split  
> the host cache, except for the elimination of h_server and sm_sticky,  
> which would be dandy if we can get away with it.  I also went to the  
> trouble of adding a SLAB for the nlm_host structures.
>
> Basically they look OK to me, except I would rename expire_hosts() as  
> nlm_expire_hosts().
>
> Would you like me to port these up to 2.6.28 and add an nlm_host SLAB?

That would be fine.  Or use your patches instead in any places where you
think there's an advantage.  The versions I sent were generated against
2.6.28-rc3, so should be recent enough.

There's a couple places (e.g. sm_sticky removal) where we need to audit
and ensure nothing's broken, and leave notes in the commit message
sufficient to reconstruct the audit.

And it'd be nice to figure out how to test nsm changes.

--b.

>
>> Anyway, the first four patches are just small cleanup and bugfixing in
>> the same area.  The remaining patches split up the client's and  
>> server's
>> host lists into two separate tables.
>>
>> They could all use another look-over and some testing; just thought  
>> you
>> might be interested as long as you're in the neighborhood.
>>
>> Also todo in vaguely the same area:
>> 	- nlmsvc_invalidate_all should be done on nfsd shutdown, but
>> 	  we're doing shutdown per transport for some reason, which
>> 	  seems dumb.  So fix that reference counting so there's just
>> 	  one count for the whole server.
>> 	- it would be nice to be able to shutdown the server
>> 	  independently of the client; currently there's no way to do
>> 	  that, as there's no way for sm-notify to distinguish client
>> 	  from server hosts.  (There may be no solution in the case
>> 	  where a single host has both client and server relationships
>> 	  with us--but people probably shouldn't be doing that anyway
>> 	  (it seems deadlock prone.)
>> 	- the debugging code in nlm_shutdown_hosts() may be overkill.
>>
>> --b.
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
