Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268Ab3C1Q0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 12:26:40 -0400
Message-ID: <51546F32.7000609@redhat.com>
Date: Thu, 28 Mar 2013 11:26:26 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
To: "Theodore Ts'o" <tytso@mit.edu>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Anand Avati <anand.avati@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
References: <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com> <20130213222052.GD5938@thunk.org> <20130213224141.GU14195@fieldses.org> <20130213224720.GE5938@thunk.org> <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com> <20130213230511.GW14195@fieldses.org> <20130213234430.GF5938@thunk.org> <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com> <5151BD5F.30607@itwm.fraunhofer.de> <5151C33E.2070008@redhat.com> <20130328140744.GA4989@thunk.org>
In-Reply-To: <20130328140744.GA4989@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/28/13 9:07 AM, Theodore Ts'o wrote:
> On Tue, Mar 26, 2013 at 10:48:14AM -0500, Eric Sandeen wrote:
>>> We don't have reached a conclusion so far, do we? What about the
>>> ioctl approach, but a bit differently? Would it work to specify the
>>> allowed upper bits for ext4 (for example 16 additional bit) and the
>>> remaining part for gluster? One of the mails had the calculation
>>> formula:
>>
>> I did throw together an ioctl patch last week, but I think Anand has a new
>> approach he's trying out which won't require ext4 code changes.  I'll let
>> him reply when he has a moment.  :)
> 
> Any update about whether Gluster can address this without needing the
> ioctl patch?  Or should we push the ioctl patch into ext4 for the next
> merge window?

I went ahead & sent the ioctl patches to the ext4 list; they are lightly
tested, and not tested at all w/ gluster AFAIK.  Wanted to get them
out just in case we decide we want them.

Thanks,
-Eric

> Thanks,
> 
> 						- Ted
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

