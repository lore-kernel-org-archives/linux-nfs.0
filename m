From: Jeff Layton <jeffrey.b.layton@lmco.com>
Subject: Re: network storage solutions - mounts
Date: Thu, 15 May 2003 13:37:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EC3D03C.7050907@lmco.com>
References: <Pine.LNX.3.96.1030514202659.14731A-100000@Maggie.Linux-Consulting.com>
Reply-To: jeffrey.b.layton@lmco.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Alvin Oga <alvin@Maggie.Linux-Consulting.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailgw1a.lmco.com ([192.31.106.7])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GMmu-0001hY-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 10:45:04 -0700
In-reply-to: <Pine.LNX.3.96.1030514202659.14731A-100000@Maggie.Linux-Consulting.com>
To: beowulf@beowulf.org
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Alvin Oga wrote:

> On Wed, 14 May 2003, Glen Kaukola wrote:
>
> > Alvin Oga wrote:
>
> some kernel folks will tell you that using soft mount WILL cause
> corrupt data  ... and that hard mount is better...
>

This is correct. The NFS homepage will explain this pretty
clearly and there's a link to a paper by Chuck Lever at
Netapps that explains it as well:

http://www.netapp.com/tech_library/3183.html

I'm cc-ing the NFS mailing list perhaps they can comment
on this.

> i prefer soft mount ... as i want the other machines to keep going,
> even if one of the other boxes died for some reason
>
> if using hardmounts, everybody sits and wait for the other server
> to come back online... if and when it does, and if it comes up
> at some other ip# or some other nfs ports, other pcs need to be
> rebooted too
>         - i dont like waiting around or rebooting
>
> hard mount vs soft mount is another vi vs emacs warz
> but at least there's more technical justifications for the reasons
>         ( i've not seen any corrupt data due to soft mounts
>         -
>         - have seens lots of people that cannot work due to hard mounts
>         - onto servers that died
>         -
>

I would hazard to say that you've been luckly. However,
the potential is there for corrupt data. I would rather wait
on the server to come back than take a chance on corrupting
data.

> trick is NO rebooting allowed, under any condition ... NOT allowed
>         - find another way to fix the problem
>         ( well, only the last person in the list/responsibility hits
>         ( the button
>
> > On the odd chance my boss does buy some duplicate
> > storage, what would you recommend I use to manage it?
>
> software raid ... on 4 IDE ports ... one drive per cable
>
> for NFS .... i'd use soft mounts
>

I'll let other people from the NFS list comment here. However,
I'd say this is risky and something I would do - especially if
you value your data.

Jeff

>
> and NOBODY gets to reboot/touch any server ...
>

-- 
Jeff Layton
Senior Engineer - Aerodynamics and CFD
Lockheed-Martin Aeronautical Company - Marietta

"Is it possible to overclock a cattle prod?" - Irv Mullins




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
