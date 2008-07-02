From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: [Patch] enable preferred realms for ccache searching
Date: Wed, 2 Jul 2008 18:09:24 +0200
Message-ID: <20080702160924.GT5111@ics.muni.cz>
References: <20080624153524.GK4484@ics.muni.cz> <4d569c330807020853m37a834ex5ba191faf85b0f97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:50657 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754209AbYGBQJn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jul 2008 12:09:43 -0400
In-Reply-To: <4d569c330807020853m37a834ex5ba191faf85b0f97-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 02, 2008 at 11:53:12AM -0400, Kevin Coffman wrote:
> I'm fixing some things up in this patch (see comments below) and I
> have a question as well:  Is "score" ever anything besides zero or
> one?  I can see how it might be used in the future for including more
> preferences, but today it is only zero or one?

The score is really only zero or one. It is there because we use one mo=
re
preference - PBSPro tickets - these have the highest priority at all bu=
t
I don't think PBS tickets are widely used so I removed this part from t=
he
public patch. Depending how close is release of 1.1.3 utils but we may =
want
allow to add dynamic settings of score to be read from a config file. O=
n the
other hand, this will be deprecated once the keyring stuff is ready.

Do you want me to rework the patch according to your comments?

Also, if interested, I have a patch to set the default preferred realm =
from the
kerberos configuration.

Thanks anyway.=20

--=20
Luk=E1=B9 Hejtm=E1nek
