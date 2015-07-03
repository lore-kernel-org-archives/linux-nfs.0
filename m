Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59665 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849AbbGCJmR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 05:42:17 -0400
Date: Fri, 3 Jul 2015 10:42:10 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
Message-ID: <20150703094210.GR17109@ZenIV.linux.org.uk>
References: <20150702041046.GG17109@ZenIV.linux.org.uk>
 <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
 <20150702075932.GI17109@ZenIV.linux.org.uk>
 <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
 <20150702082529.GJ17109@ZenIV.linux.org.uk>
 <20150702084208.GK17109@ZenIV.linux.org.uk>
 <55952C6D.50805@samsung.com>
 <20150702164332.GL17109@ZenIV.linux.org.uk>
 <20150702164926.GN17109@ZenIV.linux.org.uk>
 <55964593.1070507@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55964593.1070507@samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 03, 2015 at 11:19:31AM +0300, Andrey Ryabinin wrote:
> On 07/02/2015 07:49 PM, Al Viro wrote:
> > On Thu, Jul 02, 2015 at 05:43:32PM +0100, Al Viro wrote:
> >>  	req->tc->tag = tag-1;
> >> +	if (req->status != REQ_STATUS_IDLE)
> >> +		pr_err("using tag %d with odd status (%d)", tag, req->status);
> > 
> > Should be tag - 1 here, actually.
> 
> So, with this change:
> 
> [   81.654695] 9pnet: late delivery, tag 2 already freed
> [   81.655186] 9pnet: mismatched reply [tag = 2]
> [   85.014795] 9pnet: late delivery, tag 4 already freed
> [   85.015753] 9pnet: late delivery, tag 4 already freed
> [   85.016473] 9pnet: late delivery, tag 4 already freed
> [   87.275842] 9pnet: mismatched reply [tag = 5]
> [   88.943223] 9pnet: late delivery, tag 4 already freed
> [   88.943790] 9pnet: late delivery, tag 4 already freed
> [   88.944320] 9pnet: late delivery, tag 4 already freed
> [   88.945050] 9pnet: mismatched reply [tag = 4]
> [  105.551220] 9pnet: late delivery, tag 3 already freed
> [  105.552065] 9pnet: late delivery, tag 3 already freed
> [  114.528467] 9pnet: late delivery, tag 4 already freed
> [  164.791295] 9pnet: late delivery, tag 2 already freed
> [  164.792156] 9pnet: using tag 2 with odd status (4)
> [  164.864398] 9pnet: mismatched reply [tag = 4]
> [  166.419993] 9pnet: mismatched reply [tag = 3]
> [  174.062625] 9pnet: late delivery, tag 3 already freed
> [  174.063121] 9pnet: late delivery, tag 3 already freed
> [  174.063637] 9pnet: late delivery, tag 3 already freed
> [  174.064018] 9pnet: late delivery, tag 3 already freed
> [  174.064547] 9pnet: mismatched reply [tag = 3]
> [  175.418729] 9pnet: late delivery, tag 3 already freed
> [  177.911727] 9pnet: mismatched reply [tag = 1]
> [  235.748520] 9pnet: late delivery, tag 1 already freed
> [  235.749595] 9pnet: using tag 1 with odd status (4)
> [  243.496782] 9pnet: late delivery, tag 6 already freed
> [  243.497697] 9pnet: late delivery, tag 6 already freed
> [  243.499079] 9pnet: mismatched reply [tag = 6]
> [  243.736388] 9pnet: late delivery, tag 1 already freed
> [  243.740019] 9pnet: late delivery, tag 1 already freed
> [  248.337712] 9pnet: late delivery, tag 2 already freed
> [  249.872950] 9pnet: mismatched reply [tag = 9]
> [  252.448858] 9pnet: mismatched reply [tag = 8]
> [  252.668878] 9pnet: mismatched reply [tag = 11]

FWIW, I'd reproduced it here as well.  With the addition of checking in
p9_client_cb() whether the tag is already freed in IDR, reporting ->status
when it's not "sent" and reporting Tflush, I've got this:

[ 2754.713015] 9pnet: flushing 1
[ 2755.516123] 9pnet: flush 1 [3]done
[ 2758.443265] 9pnet: flushing 16
[ 2768.655768] 9pnet: flush 16 [8]done
[ 2783.939538] 9pnet: flushing 30
[ 2786.067856] 9pnet: flush 30 [3]done
[ 2809.784119] 9pnet: [ffff880113213000] delivery in 0, tag 1
[ 2809.948681] 9pnet: [ffff880113213000] using tag 1 with odd status (4)

Here we have delivery when that sucker is into p9_free_req(), but hasn't
removed from IDR yet.

[ 2809.948681] 9pnet: [ffff880113213000] delivery in 0, tag 1
[ 2816.767861] 9pnet: [ffff880113213000] using tag 1 with odd status (4)

Ditto.

[ 2816.767861] 9pnet: flushing 4
[ 2816.769484] 9pnet: flush 4 [5]done
[ 2846.327753] 9pnet: flushing 3
[ 2854.876131] 9pnet: flush 3 [4]done
[ 2856.492801] 9pnet: flushing 6
[ 2857.675642] 9pnet: flush 6 [1]done
[ 2860.051701] 9pnet: [ffff880113213000] delivery in 0, tag 1
[ 2860.052941] 9pnet: [ffff880113213000] late delivery, tag 1 already freed in IDR
[ 2860.680181] 9pnet: [ffff880113213000] using tag 1 with odd status (4)

This has hit between p9_free_req() and reallocating that request.

[ 2909.911815] 9pnet: [ffff880113213000] delivery in 4, tag 1
[ 2909.913145] 9pnet: [ffff880113213000] late delivery, tag 1 already freed in IDR

... while _this_ one has raced with p9_free_req() in a different way.

[ 2910.852202] 9pnet: flushing 3
[ 2917.985941] 9pnet: flush 3 [4]done
[ 2937.600652] 9pnet: flushing 2
[ 2939.775354] 9pnet: flush 2 [4]done
[ 2961.521600] 9pnet: [ffff880113213000] delivery in 0, tag 1
[ 2962.320383] 9pnet: [ffff880113213000] using tag 1 with odd status (4)

Same at the very first one.

[ 2962.320383] 9pnet: [ffff880113213000] delivery in 4, tag 8
[ 3001.578372] 9pnet: [ffff880113213000] delivery in 4, tag 6

Those had hit before p9_free_req().

AFAICS, we get occasional stray responses from somewhere.  And no, it doesn't
seem to be related to flushes or to dropping chan->lock in req_done() (this
run had been with chan->lock taken on the outside of the loop).

What I really don't understand is WTF is it playing with p9_tag_lookup() -
it's stashing req->tc via virtqueue_add_sgs() opaque data argument, fetches
it back in req_done(), then picks ->tag from it and uses p9_tag_lookup() to
find req.  Why not simply pass req instead?  I had been wrong about that
p9_tag_lookup() being able to return NULL, but why bother with it at all?
