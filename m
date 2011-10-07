Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-annu.mail.uoguelph.ca ([131.104.91.36]:31719 "EHLO
	esa-annu.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758321Ab1JGBv5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Oct 2011 21:51:57 -0400
Date: Thu, 6 Oct 2011 21:42:23 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>,
        nfsv4 <nfsv4@ietf.org>, "Matt W. Benjamin" <matt@linuxbox.com>
Message-ID: <1579920738.2729006.1317951743769.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <1317871693.14305.5.camel@lade.trondhjem.org>
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION,
 BIND_CONN_TO_SESSION
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2011-10-05 at 19:21 -0400, Matt W. Benjamin wrote:
> > Hi,
> >
> > There seem to be legitimate reasons for an (NFSv4.1) client and/or
> > server to prefer a dedicated callback channel.
> 
> That would be an assertion that is missing a lot of context and
> explanation. Why should my client bother to support such a server?
> 
> > If a server wants this result, it seems from the language of 18.36.3
> > that it should indicate it by not setting
> > CREATE_SESSION4_FLAG_CONN_BACK_CHAN in csr_flags in the
> > CREATE_SESSION response, presuming the flag is set in the
> > corresponding csa_flags argument (it's not allowed to set it
> > otherwise). The client may respond with BIND_CONN_TO_SESSION on a
> > new channel, setting bctsa_dir to CDFC4_BACK.
> 
> Nope. The exact wording is:
> 
> If CREATE_SESSION4_FLAG_CONN_BACK_CHAN is set in csa_flags, the
> client is requesting that the connection over which the
> CREATE_SESSION operation arrived be associated with the
> session's backchannel in addition to its fore channel. If the
> server agrees, it sets CREATE_SESSION4_FLAG_CONN_BACK_CHAN in
> the result field csr_flags. If
> CREATE_SESSION4_FLAG_CONN_BACK_CHAN is not set in csa_flags,
> then CREATE_SESSION4_FLAG_CONN_BACK_CHAN MUST NOT be set in
> csr_flags.
> 
> I see nothing there to indicate that the server is able to request a
> dedicated backchannel. All it says is that the server may refuse a
> backchannel on this particular connection.
> 
> > Currently, the Linux and I believe also the CITI Windows client
> > always propose channels in both directions. The Linux mainline Linux
> > client doesn't know how to BIND_CONN_TO_SESSION, so trivially it
> > won't negotiate any back channel if a server didn't agree to both
> > directions today, either. I've experimentally implemented a
> > "fallback" model in a Linux client and (partly in a) Ganesha server.
> > I'd appreciate any feedback on the idea.
> 
> Yep. As I said, why should we bother adding support for servers that
> don't? I can function perfectly well without pNFS support or
> delegation
> support in such a case. Performance will suck, but why do I care?
> 
Just fyi, what I have implemented (and I don't intend to change it) is
what Trond currently has done. For the FreeBSD 4.1 client, it will set
CREATE_SESSION4_FLAG_CONN_BACK_CHAN in csa_flags, but if the server
doesn`t set it in csr_flags, I simply assume `no backchannel`. I
don`t plan on implementing a dedicated back channel. (I suppose that
could change if there were strong evidence that a dedicated back channel
did improve performance significantly.)

I thought I`d post this mainly to show that there are actually times when I
agree with Trond;-) rick

