From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 0/2] pnfs-submit Re-initialize pnfs_layout_type when segs
	list is empty
Date: Mon, 12 Jul 2010 12:36:56 -0400
Message-ID: <AANLkTinjab9XPUjRe2knYyRQg8j9pmc9Gdk_fRkGGfY2@mail.gmail.com>
References: <1278693571-3328-1-git-send-email-andros@netapp.com>
	<4C3B395F.8080903@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47905 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab0GLQg5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 12:36:57 -0400
Received: by gye5 with SMTP id 5so2601687gye.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2010 09:36:57 -0700 (PDT)
In-Reply-To: <4C3B395F.8080903@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 12, 2010 at 11:48 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 07/09/2010 07:39 PM, andros@netapp.com wrote:
>> e keep the nfs_inode->layout when the segs list is empty, and we remove it
>> from the nfs_client cl_layouts list, but we fail to reset the other fields.
>> Re-initialize the layout (all except for the refcount) so that the next
>> layoutget with potentially new deviceid.... sets the layout fields.
>>
>> Note: API change to layoutdriver_io_operations free_layout
>>
>> 0001-SQUASHME-pnfs-submit-reinitialize-pnfs_layout_type.patch
>> 0002-SQUASHME-pnfs-submit-file-layout-free_layout-init_on.patch
>>
>> Tested
>>
>> CONFIG_V4_I set:
>> Connectathon tests pass against GFS2/pNFS and pyNFS file layout servers. Both
>> return-on-close and not return-on-close tested.
>>
>> CONFIG_V4_I not set:
>> NFSv4.0 mount passes Connectathon tests.
>>
>> -->Andy
>>
>
> Andy sorry to get on your case. But I hate it. It is an hack that takes
> us back not forward. (Code less clean more obscure)
>
> For starts don't save me a vector please. The two functions are unrelated
> see your last patch 0002 there is no common code and a return in the middle
> of an if() which should trigger an alarm for a bad API.

OK, that would be more clear.

>
> Second if at all, then the costume is to initialize on re-use not on end
> of previous operation. (Clearer intentions, might not be reused, etc...)

We need to zero the stateid at the return of the last layout segment.
Once we return the last segment, we signal the server that the layout
stateid is no longer in use and it can dispose of the layout state.

8.2.1. Stateid Types

      A stateid represents the set of all layouts held by a particular
      client for a particular filehandle with a given layout type.


12.5.3. Layout Stateid


   As with all other stateids, the layout stateid consists of a "seqid"
   and "other" field.  Once a layout stateid is established, the "other"
   field will stay constant unless the stateid is revoked or the client
   returns all layouts on the file and the server disposes of the
   stateid.

Once the stateid is no longer valid, the rest of the layout follows suit.


>
> 3rd, if you'd follow my original proposal you'll see that this hack is not
> needed.

If by you're original proposal you mean have the nfs_inode->layout
follow the life of the nfs_inode it is indeed needed!  You still need
to zero the stateid at the return of the last layout segment. You
still can't assume that any fields of the layout received from a
LAYOUTGET after you cleared the nfs_inode->layout->segs list will be
the same as the old layout returned. So, you need to re-initialize the
nfs_inode->layout.

>
> If these patches fix an actual bug you've been hitting, could you just fix
> the particular field in question that needs zeroing. And we can see how to
> solve it better.

The actual bug we are hitting is that we keep the stateid past the
last layout segment, and actually re-use it on a subsequent LAYOUTGET
(send_layout)

I should have added this to the patch comments.

-->Andy
>
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
