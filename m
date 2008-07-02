From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [Patch] enable preferred realms for ccache searching
Date: Wed, 2 Jul 2008 13:18:46 -0400
Message-ID: <4d569c330807021018ka2c6ad6t573caae886fb5307@mail.gmail.com>
References: <20080624153524.GK4484@ics.muni.cz>
	 <4d569c330807020853m37a834ex5ba191faf85b0f97@mail.gmail.com>
	 <20080702160924.GT5111@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>,
	"Linux NFS Mailing list" <linux-nfs@vger.kernel.org>,
	"Linux NFSv4 mailing list" <nfsv4@linux-nfs.org>
To: "Lukas Hejtmanek" <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:45331 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbYGBRSr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 13:18:47 -0400
Received: by yw-out-2324.google.com with SMTP id 9so200260ywe.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2008 10:18:47 -0700 (PDT)
In-Reply-To: <20080702160924.GT5111@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2008/7/2 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
> On Wed, Jul 02, 2008 at 11:53:12AM -0400, Kevin Coffman wrote:
>> I'm fixing some things up in this patch (see comments below) and I
>> have a question as well:  Is "score" ever anything besides zero or
>> one?  I can see how it might be used in the future for including more
>> preferences, but today it is only zero or one?
>
> The score is really only zero or one. It is there because we use one more
> preference - PBSPro tickets - these have the highest priority at all but
> I don't think PBS tickets are widely used so I removed this part from the
> public patch.

OK, I'll leave that part alone then.

> Depending how close is release of 1.1.3 utils but we may want
> allow to add dynamic settings of score to be read from a config file. On the
> other hand, this will be deprecated once the keyring stuff is ready.
>
> Do you want me to rework the patch according to your comments?

Thanks, but I'm already cleaning it up.  I'll re-post for you look at
before sending up to Steve.

> Also, if interested, I have a patch to set the default preferred realm
> from the kerberos configuration.

I think that would be a nice thing to add to this.
