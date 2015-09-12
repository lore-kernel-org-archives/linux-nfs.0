Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:13098 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754507AbbILM1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Sep 2015 08:27:15 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Bruce James Fields <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upgrade/downgrade race
References: <m2h9n3btno.fsf@discipline.rit.edu>
	<CAHQdGtQ84tUFEXaUwSngAmQst3NbjZDCSwB2jtqRqR29R4wBWg@mail.gmail.com>
	<CAHQdGtTvPPXjSm8Aq6AefMec4UEUwL6+swwav8SSFMQJMDchCA@mail.gmail.com>
	<20150909144935.51e3653b@tlielax.poochiereds.net>
	<CAHQdGtS2BL+d9NvV5adG=Mts0Qx6_=5Fwo34+nbz-eMVepnnKg@mail.gmail.com>
	<20150909151801.3fd2243f@tlielax.poochiereds.net>
	<20150909204036.GD25750@fieldses.org>
	<20150909170037.77776b5a@tlielax.poochiereds.net>
	<20150909213907.GF25750@fieldses.org>
	<20150912081037.6658649c@tlielax.poochiereds.net>
Date: Sat, 12 Sep 2015 08:27:14 -0400
In-Reply-To: <20150912081037.6658649c@tlielax.poochiereds.net> (Jeff Layton's
	message of "Sat, 12 Sep 2015 08:10:37 -0400")
Message-ID: <m27fnvx1p9.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Andrew, could you test this patch out? This just covers open and lock
> stateids. If it works, I'll clean up the comments and resend it to the
> list as a PATCH email.

Will do, thank you!

> Assuming that it does, we'll need to consider what (if anything) to do
> about layout stateids...

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
