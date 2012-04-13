Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3.science-computing.de ([193.197.16.20]:7289 "EHLO
	mx3.science-computing.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab2DMMo6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Apr 2012 08:44:58 -0400
Date: Fri, 13 Apr 2012 14:34:57 +0200
From: Michael Weiser <M.Weiser@science-computing.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from
 pre-1.2.3 nfs-utils server
Message-ID: <20120413123457.GB23073@science-computing.de>
References: <20120313144214.GB16920@science-computing.de>
 <CAKnQG+ezssmHZCAogTuWC7+ubAn8YjUtOF1MJ0Fw4rr7Z_srhw@mail.gmail.com>
 <20120314134829.GA943@science-computing.de>
 <20120319130043.GG9020@science-computing.de>
 <4F686996.5050108@RedHat.com>
 <20120320174418.GL24828@science-computing.de>
 <20120329140226.GB1362@science-computing.de>
 <4F86EA08.5000308@RedHat.com>
 <20120412154928.GG2351@science-computing.de>
 <4F86FC8B.7050606@RedHat.com>
MIME-Version: 1.0
In-Reply-To: <4F86FC8B.7050606@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

On Thu, Apr 12, 2012 at 12:02:19PM -0400, Steve Dickson wrote:

> > Here it is. The whole HAVE_SET_ALLOWABLE_ENCTYPES logic is still in place
> > but my code now ignores it. So with a GSSAPI implementation that doesn't
> > support it, the -l switch will be accepted by gssd but silently do
> > nothing.
> Well after further review.... it appears remove moving those defines would
> have a negative impact on backwards compatibility with older Kerberos 
> libraries. 

> So what I'm thinking of doing is error out if an admin tries to use the 
> -l flag with incompatible  Kerberos libraries. I also made a note in
> the man page. So how about something like this:

No arguments from me. Seems a great solution.

> If this seems reasonable, would you mind giving it a test run to 
> ensure I have not broken anything? tia..

I gave it a spin on my RHEL6 VM and everything still works.

Compiling with HAVE_SET_ALLOWABLE_ENCTYPES undefined produces a gssd
that bails as intended:

[root@rhel6 gssd]# ./gssd -vvv -f -l
gssd: Setting encryption type not support by Kerberos libraries.

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

