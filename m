From: Douglas Furlong <douglas.furlong@firebox.com>
Subject: Re: NFS server not responding
Date: Tue, 02 Dec 2003 14:37:45 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1070375865.20333.74.camel@wibbit.firebox.com>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
	 <shsptfch1om.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARBf3-0006je-9W
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 06:37:57 -0800
Received: from dsl-217-155-91-196.zen.co.uk ([217.155.91.196] helo=helium.firebox.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1ARBf2-0000k8-J6
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 06:37:56 -0800
Received: from localhost (helium.firebox.com [127.0.0.1])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hB2ETn9e012266
	for <nfs@lists.sourceforge.net>; Tue, 2 Dec 2003 14:29:49 GMT
Received: from helium.firebox.com ([127.0.0.1])
 by localhost (helium.firebox.com [127.0.0.1]) (amavisd-new, port 10024)
 with LMTP id 12136-05 for <nfs@lists.sourceforge.net>;
 Tue,  2 Dec 2003 14:29:48 +0000 (GMT)
Received: from [192.168.0.150] (wibbit.firebox.com [192.168.0.150])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hB2EThUh012255
	for <nfs@lists.sourceforge.net>; Tue, 2 Dec 2003 14:29:44 GMT
To: nfs@lists.sourceforge.net
In-Reply-To: <shsptfch1om.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 2003-11-28 at 16:56, Trond Myklebust wrote:
> >>>>> " " == Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> writes:
> 
> 
>      > I also see something like 0.8-1% retransmissions and these
>      > messages on newly installed Fedora Core 1 on some cluster
>      > nodes, using default r/wsize (8192). As I'm using root-NFS, the
>      > node is quite useless when this situation happens. I'm sure
> 
> Huh? Why should a 1% retransmission make a noticable difference? Be
> realistic: we're talking about a delay of 100ms on 1/100 requests...

If this was the case then i would agree that there is no problem at all,
but I am noticing delays of three or four seconds when opening up a new
mail in Evolution, or downloading new mail off of the IMAP server (which
get stored in the users home directory on the NFS server). When typing
in to a mail I will find the text freezes for several seconds, which is
fine for me (touch type with accuracy) but other people that are less
secure working on PC (read most people I deal with), they find this sort
of behaviour unacceptable (which i agree with).

I have found that all of these error's coincide with the NFS server not
responding error messages. Before making the changes to the retrans
values I was finding messages appearing as "blank" in evolution as the
initial download from the IMAP server would fail due to not being able
to write to disk, however evolution would think that it had, and would
just show empty emails (exceedingly annoying).
Now I am not receiving any error messages just moments when applications
"freeze", the rest of the system is fine, and I just have to give it a
few seconds and all is back to normal.

> I get ~2% retransmission rate when I do UDP loopback mounts without
> seeing any problems at all: it still compares well to the same mount
> using TCP.

I thought I had enabled this, but it turns out I have not, as I need to
enable NFS over TCP on the server (I think), I have not had a chance to
do that yet.

Douglas



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
