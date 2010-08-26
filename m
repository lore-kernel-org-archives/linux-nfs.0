Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54689 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737Ab0HZVnq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 17:43:46 -0400
Date: Fri, 27 Aug 2010 07:43:39 +1000
From: Neil Brown <neilb@suse.de>
To: Peng Yu <pengyu.ut@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Does the machine need to be restarted after RPCNFSDCOUNT in
 /etc/default/nfs-kernel-server (ubuntu) is edited?
Message-ID: <20100827074339.605f58c7@notabene>
In-Reply-To: <AANLkTincnCeQYi6fvbEHLqqz+gYp0_ETdPAq6QebOxDg@mail.gmail.com>
References: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
	<20100826093648.26d03c1c@notabene>
	<AANLkTincnCeQYi6fvbEHLqqz+gYp0_ETdPAq6QebOxDg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 26 Aug 2010 06:59:16 -0500
Peng Yu <pengyu.ut@gmail.com> wrote:

> On Wed, Aug 25, 2010 at 6:36 PM, Neil Brown <neilb@suse.de> wrote:
> > On Wed, 25 Aug 2010 15:02:14 -0500
> > Peng Yu <pengyu.ut@gmail.com> wrote:
> >
> >> Hi,
> >>
> >> I changed the value of RPCNFSDCOUNT in /etc/default/nfs-kernel-server
> >> (ubuntu). Do I need to restart the machine?
> >>
> >> Or I need to restart nfsd? If so, would you please let me know how to
> >> restart nfsd?
> >>
> >
> > Easiest thing to do is simply
> >
> >   rpc.nfsd $NUMBER
> >
> > it will change the number of running threads to match the number that you
> > give.
> 
> This will change the number in /etc/default/nfs-kernel-server? Or it
> will not, meaning if I reboot machine, there will still be an old
> number of nfsd running?
> 

Try it an see ???


No, it doesn't change any file.  It just changes the number of running
threads.

If you want to change the number of threads at next reboot, change the file.
If you want to change the number of threads running now, run the command.
If you want to do both, do both.

NeilBrown
