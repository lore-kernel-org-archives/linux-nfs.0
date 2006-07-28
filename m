From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: default sunrpc.min_resvport
Date: Fri, 28 Jul 2006 14:46:41 -0400
Message-ID: <76bd70e30607281146r1c485578kb80cea2993a9c06@mail.gmail.com>
References: <168996D6C4DFA945B032B63C0DEAA6BF0421EA7D@EXCHANGE1.postini.com>
	<44CA5849.6050509@atipa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6XMA-000285-Tn
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 11:46:43 -0700
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6XMA-0008Cn-T7
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 11:46:43 -0700
Received: by nf-out-0910.google.com with SMTP id m19so273401nfc
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 11:46:41 -0700 (PDT)
To: "Christopher M. Smith" <cms@kronos.net>
In-Reply-To: <44CA5849.6050509@atipa.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 7/28/06, Roger Heflin <rheflin@atipa.com> wrote:
> Michael Han wrote:
> >>From Chuck Lever:
> >> "For the record," some sites have a requirement for a larger
> >> port space.
> >
> > Naturally they do. auto-home systems with thousands of users could
> > easily cause this. I'm just pointing out that I'm satisfied with my own
> > workaround.
> >
> >> The daemon actually wouldn't show up on the security scan.  The
> >> hardware IPMI listener would, however.  The daemon is not visible on
> >> the network because the IPMI listener diverts packets to that port.
> >
> > Of course, you are correct. That's the crux of the problem I
> > encountered. Silly me.
> >
> >> Other workarounds worth mentioning: disable IPMI in the hardware, or
> >> don't use the built-in NIC for NFS traffic.
> >
> > Yes. Another possible alternative is to divert IPMI traffic to an
> > IPMI-only address. I'm not certain this works, but I know the SuperMicro
> > BMCs support use of alternate MAC & IP. I just don't know if the port
> > 623/664 intercepts are promiscuous. I tried changing this on a hot
> > system to no avail, but not after rebooting a system and all that good
> > stuff.
> >
> >> Indeed.  I'm not familiar enough with IPMI to know if it listens on
> >> both the UDP and the TCP port.
> >
> > I believe that in all implementations, IPMI only uses UDP
> > conventionally, however the port allocation from IANA is for both
> > transports and it appears that more than one implementation intercepts
> > both transports (I've seen this issue referenced on systems using Intel
> > NICs with IPMI support and on Sun x86 hardware). I'm pretty uneducated
> > as far as IPMI goes, myself.
> >
>
>
> Some versions (maybe all) of broadcom chips will intercept *ANY* udp frame
> with the proper port number in the proper byte, even if that byte is not
> a port number, ie they will intercept the additional frames that make up a
> 32k udp packet that has the proper data in the port space, even though it
> is not a port number as the extra frames don't have a port designation.
>
> The broadcom chip is doing this in firmware, and it results in the nth
> frame of a 32k udp packet always being lost even on retransmit, and it
> very much depends on the data being sent to have the wrong number in
> the wrong location, and it has been reported to Broadcom.
>
> It means that it is difficult to run the Broadcom ethernet ports with ipmi
> the same ip/mac address and have things reliable.
>
> The last time I worked with the intel e1000's bmc they were troublesome and
> unreliable in many other different way,s though that may be fixed now.
>
> None of the IPMI variants I have dealt with have been "reliable" they all
> seem to have major issues of various sorts, ie they don't always work
> exactly right, and if you are doing Serial over lan, things were even
> worse.

Chris-

Can you craft a diplomatically worded FAQ entry that encapsulates this
issue (without pointing fingers at specific NIC vendors ;-) ?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
