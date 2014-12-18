Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35163 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbaLRO6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 09:58:11 -0500
Date: Thu, 18 Dec 2014 09:58:06 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: =?ISO-8859-15?Q?Holger_Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
In-Reply-To: <20141218144856.GA18179@fieldses.org>
Message-ID: <alpine.OSX.2.19.9992.1412180955000.62182@planck.local>
References: <pan.2014.12.16.22.19.18@googlemail.com> <20141217212159.GA11517@fieldses.org> <5492C710.20104@googlemail.com> <20141218144856.GA18179@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="0-675064800-1418914689=:62182"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-675064800-1418914689=:62182
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

Frame 36 of nfs-client.pcap has this interesting string:

0ff0  00 01 3b f6 fb b6 26 16 8f 7c 00 00 00 41 62 74   ..;...&..|...Abt
1000  72 66 73 2d 32 30 00 00 00 00 00 00 00 00 30 36   rfs-20........06
1010  2d 66 69 78 2d 64 65 61 64 6c 6f 63 6b 2d 77 68   -fix-deadlock-wh
1020  65 6e 2d 6d 6f 75 6e 74 69 6e 67 2d 61 2d 64 65   en-mounting-a-de
1030  67 72 61 64 65 64 2d 66 73 2e 70 61 74 63 68 00   graded-fs.patch.

...

Ben

On Thu, 18 Dec 2014, J. Bruce Fields wrote:

> On Thu, Dec 18, 2014 at 01:22:40PM +0100, Holger Hoffstätte wrote:
> > On 12/17/14 22:22, J. Bruce Fields wrote:
> > > On Tue, Dec 16, 2014 at 10:19:18PM +0000, Holger Hoffstätte wrote:
> > >> (..oddly broken directory over NFS..)
> > > That doesn't sound familiar.  A network trace showing the READDIR would
> > > be really useful.  Since this is so reproducible, I think that should be
> > > possible.  So do something like:
> > >
> > > 	move the problem file into 3.14/
> > > 	tcpdump -s0 -wtmp.pcap -i<relevant interface>
> > > 	ls the directory on the client.
> > > 	kill tcpdump
> > > 	send us tmp.pcap and/or take a look at it with wireshark and see
> > > 	what the READDIR response looks like.
> >
> > Thanks for your reply. I forgot to mention that removing other files seems to "fix" the problem, so it does not seem to be spefically the new file itself that is the cause.
> >
> > I captured the "ls 3.14 | head" sequence on both the client and the server, and put the tcpudmp files here: http://hoho.duckdns.org/linux/ - let me know if that helped.
>
> On a quick skim, the server's READDIR responses look correct.  The entry
> btrfs-20141216-fix-a-warning-of-qgroup-account-on-shared-extents.patch
> is returned in frame 53 (with complete reassembled reply displayed by
> wireshark in frame 63).
>
> You could double-check for me--just run "wireshark nfs-server.pcap",
> look for packets labeled "Reply ... READDIR", and expand out the READDIR
> op and directory listing.  I don't see anything obviously wrong.
>
> It's interesting that there's only one LOOKUP in the trace, for btrfs-20
> (returning, not suprisingly, NFS4ERR_NOENT).  If the client failed to
> parse that entry for some reason, then maybe in addition to getting the
> filename wrong it also failed to get the attributes, triggering the
> extra lookup/getattr.
>
> > Meanwhile I'll try older/plain (unpatched) kernels. So far reverting the client to vanilla 3.18.1 or 3.14.27 has not helped..
>
> I'm a little unclear: when you said "All this is on freshly baked
> 3.18.1", are you describing the client, or the server, or both?
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
--0-675064800-1418914689=:62182--
