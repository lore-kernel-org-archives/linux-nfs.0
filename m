Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3.science-computing.de ([193.197.16.20]:11068 "EHLO
	mx3.science-computing.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758840Ab2C2OMU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2012 10:12:20 -0400
Date: Thu, 29 Mar 2012 16:02:26 +0200
From: Michael Weiser <M.Weiser@science-computing.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from
 pre-1.2.3 nfs-utils server
Message-ID: <20120329140226.GB1362@science-computing.de>
References: <20120312200221.GS29573@science-computing.de>
 <CAKnQG+dq4C+dw5W2Jgcgg7xk-Kj_-hxLnCbeR8879tZ7DMt3jA@mail.gmail.com>
 <5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de>
 <CAKnQG+f3cG0q8Zoan=cc85qD5MUqqiwgnxFeq1ygTmGip+Kp5w@mail.gmail.com>
 <20120313144214.GB16920@science-computing.de>
 <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com>
 <20120314134829.GA943@science-computing.de>
 <20120319130043.GG9020@science-computing.de>
 <4F686996.5050108@RedHat.com>
 <20120320174418.GL24828@science-computing.de>
MIME-Version: 1.0
In-Reply-To: <20120320174418.GL24828@science-computing.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

On Tue, Mar 20, 2012 at 06:44:18PM +0100, Michael Weiser wrote:

> > > If nobody objects, I'd resubmit my patch to gssd with some cleanup and
> > > documentation.\
> > No, Please do...
> Here's the patch. Is there any special procedure to follow to get it
> committed?

How do I go about getting this committed?

> I just noticed that while the code bits are optional based on
> HAVE_SET_ALLOWABLE_ENCTYPES, the man page part isn't. I've got no idea,
> how to go about that.

Thanks,
-- 
Michael Weiser                science + computing ag
Senior Systems Engineer       Geschaeftsstelle Duesseldorf
                              Martinstrasse 47-55, Haus A
phone: +49 211 302 708 32     D-40223 Duesseldorf
fax:   +49 211 302 708 50     www.science-computing.de
-- 
Vorstandsvorsitzender/Chairman of the board of management:
Gerd-Lothar Leonhart
Vorstand/Board of Management:
Dr. Bernd Finkbeiner, Michael Heinrichs, 
Dr. Arno Steitz, Dr. Ingrid Zech
Vorsitzender des Aufsichtsrats/
Chairman of the Supervisory Board:
Philippe Miltin
Sitz/Registered Office: Tuebingen
Registergericht/Registration Court: Stuttgart
Registernummer/Commercial Register No.: HRB 382196

