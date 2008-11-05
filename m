From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/18] kernel NSM support for IPv6 (take 2)
Date: Wed, 5 Nov 2008 17:41:51 -0500
Message-ID: <F4260CE3-3780-4EF2-9CCA-0355F32D1133@oracle.com>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net> <20081105194955.GA1455@fieldses.org> <20081105204517.GC1455@fieldses.org> <61853126-2B02-44C8-B47B-C4CD8618EF0C@oracle.com> <20081105215030.GL1455@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23184 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080AbYKEWmH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 17:42:07 -0500
In-Reply-To: <20081105215030.GL1455@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 5, 2008, at 4:50 PM, J. Bruce Fields wrote:
> On Wed, Nov 05, 2008 at 04:34:01PM -0500, Chuck Lever wrote:
>> On Nov 5, 2008, at 3:45 PM, J. Bruce Fields wrote:
>>> On Wed, Nov 05, 2008 at 02:49:55PM -0500, bfields wrote:
>>>> By the way, I did some miscellaneous nsm cleanup a few months ago  
>>>> and
>>>> never got around to sending it out.  I'll pass that along in a
>>>> moment.
>>>
>>> For which I meant to send out a cover letter and forgot, sorry!
>>
>> These look similar to some prototype patches I've played with to  
>> split
>> the host cache, except for the elimination of h_server and sm_sticky,
>> which would be dandy if we can get away with it.  I also went to the
>> trouble of adding a SLAB for the nlm_host structures.
>>
>> Basically they look OK to me, except I would rename expire_hosts() as
>> nlm_expire_hosts().
>>
>> Would you like me to port these up to 2.6.28 and add an nlm_host  
>> SLAB?
>
> That would be fine.  Or use your patches instead in any places where  
> you
> think there's an advantage.  The versions I sent were generated  
> against
> 2.6.28-rc3, so should be recent enough.

OK, I can do that.  I'll apply most of your patches after the NSM IPv6  
patches and the SLAB-ify patches.  There might be some additional  
optimizations, and I haven't figured out what to do about the  
"redundant RPC client shutdown" question you raised.

> There's a couple places (e.g. sm_sticky removal) where we need to  
> audit
> and ensure nothing's broken, and leave notes in the commit message
> sufficient to reconstruct the audit.

I might postpone these (either drop them, or put them at the end) so  
we can have some more time to think carefully about what needs to be  
done here.  As I said before, IMO it would be cleaner to go without  
h_server and sm_sticky, so I'm in favor of making these patches work  
if possible.

> And it'd be nice to figure out how to test nsm changes.

Hah!  ;-)

> --b.
>
>>
>>> Anyway, the first four patches are just small cleanup and  
>>> bugfixing in
>>> the same area.  The remaining patches split up the client's and
>>> server's
>>> host lists into two separate tables.
>>>
>>> They could all use another look-over and some testing; just thought
>>> you
>>> might be interested as long as you're in the neighborhood.
>>>
>>> Also todo in vaguely the same area:
>>> 	- nlmsvc_invalidate_all should be done on nfsd shutdown, but
>>> 	  we're doing shutdown per transport for some reason, which
>>> 	  seems dumb.  So fix that reference counting so there's just
>>> 	  one count for the whole server.
>>> 	- it would be nice to be able to shutdown the server
>>> 	  independently of the client; currently there's no way to do
>>> 	  that, as there's no way for sm-notify to distinguish client
>>> 	  from server hosts.  (There may be no solution in the case
>>> 	  where a single host has both client and server relationships
>>> 	  with us--but people probably shouldn't be doing that anyway
>>> 	  (it seems deadlock prone.)
>>> 	- the debugging code in nlm_shutdown_hosts() may be overkill.
>>>
>>> --b.
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



