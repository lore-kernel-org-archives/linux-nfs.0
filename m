From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 0/2] pnfs-submit Re-initialize pnfs_layout_type when segs
 	list is empty
Date: Mon, 12 Jul 2010 20:07:31 +0300
Message-ID: <4C3B4BD3.1090308@panasas.com>
References: <1278693571-3328-1-git-send-email-andros@netapp.com>	<4C3B395F.8080903@panasas.com> <AANLkTinjab9XPUjRe2knYyRQg8j9pmc9Gdk_fRkGGfY2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22710 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755913Ab0GLRHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 13:07:38 -0400
In-Reply-To: <AANLkTinjab9XPUjRe2knYyRQg8j9pmc9Gdk_fRkGGfY2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/12/2010 07:36 PM, William A. (Andy) Adamson wrote:
> On Mon, Jul 12, 2010 at 11:48 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 07/09/2010 07:39 PM, andros@netapp.com wrote:
>>> e keep the nfs_inode->layout when the segs list is empty, and we remove it
>>> from the nfs_client cl_layouts list, but we fail to reset the other fields.
>>> Re-initialize the layout (all except for the refcount) so that the next
>>> layoutget with potentially new deviceid.... sets the layout fields.
>>>
>>> Note: API change to layoutdriver_io_operations free_layout
>>>
>>> 0001-SQUASHME-pnfs-submit-reinitialize-pnfs_layout_type.patch
>>> 0002-SQUASHME-pnfs-submit-file-layout-free_layout-init_on.patch
>>>
>>> Tested
>>>
>>> CONFIG_V4_I set:
>>> Connectathon tests pass against GFS2/pNFS and pyNFS file layout servers. Both
>>> return-on-close and not return-on-close tested.
>>>
>>> CONFIG_V4_I not set:
>>> NFSv4.0 mount passes Connectathon tests.
>>>
>>> -->Andy
>>>
>>
>> Andy sorry to get on your case. But I hate it. It is an hack that takes
>> us back not forward. (Code less clean more obscure)
>>
>> For starts don't save me a vector please. The two functions are unrelated
>> see your last patch 0002 there is no common code and a return in the middle
>> of an if() which should trigger an alarm for a bad API.
> 
> OK, that would be more clear.
> 
>>
>> Second if at all, then the costume is to initialize on re-use not on end
>> of previous operation. (Clearer intentions, might not be reused, etc...)
> 
> We need to zero the stateid at the return of the last layout segment.
> Once we return the last segment, we signal the server that the layout
> stateid is no longer in use and it can dispose of the layout state.
> 

Sure then we should have some _on_last_segment state somewhere, for example
when removing from client-list, right? Free the stateid there, and call it
free_stateid. and not call it reinit().

And is this a layoutdriver specific? It looks like generic business only.

> 8.2.1. Stateid Types
> 
>       A stateid represents the set of all layouts held by a particular
>       client for a particular filehandle with a given layout type.
> 
> 
> 12.5.3. Layout Stateid
> 
> 
>    As with all other stateids, the layout stateid consists of a "seqid"
>    and "other" field.  Once a layout stateid is established, the "other"
>    field will stay constant unless the stateid is revoked or the client
>    returns all layouts on the file and the server disposes of the
>    stateid.
> 
> Once the stateid is no longer valid, the rest of the layout follows suit.
> 
> 
>>
>> 3rd, if you'd follow my original proposal you'll see that this hack is not
>> needed.
> 
> If by you're original proposal you mean have the nfs_inode->layout
> follow the life of the nfs_inode it is indeed needed!  You still need
> to zero the stateid at the return of the last layout segment. You
> still can't assume that any fields of the layout received from a
> LAYOUTGET after you cleared the nfs_inode->layout->segs list will be
> the same as the old layout returned. So, you need to re-initialize the
> nfs_inode->layout.
> 

By now you should have a on_first_segment/on_last_segment states in code.
Generic part should clean sweep at on_first_segment state.

If you have a particular layout-driver specific initialization, LD can
check if segment is first in alloc_lseg and take care of itself. (Or
a flag could be supplied for the lazy)

>>
>> If these patches fix an actual bug you've been hitting, could you just fix
>> the particular field in question that needs zeroing. And we can see how to
>> solve it better.
> 
> The actual bug we are hitting is that we keep the stateid past the
> last layout segment, and actually re-use it on a subsequent LAYOUTGET
> (send_layout)
> 

As I said above: on_last_segment/remove-from-client-list can call a specific
free_lo_stateid, could be nice for readability.

> I should have added this to the patch comments.
> 
> -->Andy
>>
>> Thanks
>> Boaz

Boaz
