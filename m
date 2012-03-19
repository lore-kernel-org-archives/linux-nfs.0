Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.science-computing.de ([193.197.16.30]:59656 "EHLO
	mx4.science-computing.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab2CSNKh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 09:10:37 -0400
Date: Mon, 19 Mar 2012 14:00:43 +0100
From: Michael Weiser <M.Weiser@science-computing.de>
To: Kevin Coffman <kwc@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from
 pre-1.2.3 nfs-utils server
Message-ID: <20120319130043.GG9020@science-computing.de>
References: <20120312200221.GS29573@science-computing.de>
 <CAKnQG+dq4C+dw5W2Jgcgg7xk-Kj_-hxLnCbeR8879tZ7DMt3jA@mail.gmail.com>
 <5dad9f48aa83cc6af5f51fb3a5c076e0.squirrel@webmail.science-computing.de>
 <CAKnQG+f3cG0q8Zoan=cc85qD5MUqqiwgnxFeq1ygTmGip+Kp5w@mail.gmail.com>
 <20120313144214.GB16920@science-computing.de>
 <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com>
 <20120314134829.GA943@science-computing.de>
MIME-Version: 1.0
In-Reply-To: <20120314134829.GA943@science-computing.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Kevin,
Hello list,

On Wed, Mar 14, 2012 at 02:48:29PM +0100, Michael Weiser wrote:

> So the client's ticket for the server is encrypted using arcfour-hmac
> but the session key contained therein is only des-cbc-crc.

> This behaviour works so seamlessly, that I had assumed, it's intentional.
> Are you telling me, that it is neither intended nor supported?

> If so: Isn't this something we'd want to have? I accept that it's not
> much use from an interoperability point of view but it sure simplifies
> administration in a Linux-only environment. Doesn't this also have at
> least some positive security impact? And as I've said, it greatly
> simplifies Linux admins' life in an Active Directory 2008 R2+
> environment where AD administrators will be very reluctant to change the
> domain security policy for those obscure Linux boxes.

Any thoughts on this, anyone?

If nobody objects, I'd resubmit my patch to gssd with some cleanup and
documentation.

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

