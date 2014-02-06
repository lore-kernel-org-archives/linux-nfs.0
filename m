Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3-phx2.redhat.com ([209.132.183.24]:33681 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253AbaBFMc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 07:32:26 -0500
Date: Thu, 6 Feb 2014 07:32:24 -0500 (EST)
From: Simo Sorce <ssorce@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, simo@redhat.com
Message-ID: <2007660826.5427353.1391689944179.JavaMail.root@redhat.com>
In-Reply-To: <52F138C9.7070804@RedHat.com>
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown> <20140204162052.GA5295@fieldses.org> <52F138C9.7070804@RedHat.com>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> On 02/04/2014 11:20 AM, J. Bruce Fields wrote:
> > On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
> >> On Mon, 03 Feb 2014 16:01:21 -0500 Steve Dickson <SteveD@redhat.com>
> >> wrote:
> >>> Also how does gss-proxy come to play in all this? Maybe we
> >>> just use  gss-proxy by default and retire rpc.svcgssd.
> >>
> >> I haven't really be following and so am only dimly aware of gss-proxy.
> >> It's a replacement for rpc.svcgssd - right?
> >> So we should get it to start in the same circumstances as rpc.svcgssd?
> >>
> >> Is there some easy test - eg something existing in the filesystem - that
> >> we
> >> could use to see if the kernel supports gss-proxy ?
> > 
> > There's a /proc/net/rpc/use-gss-proxy file.
> hmm... I forget... who set this... gssproxy daemon?

If gss-proxy is configured to provide the kernel nfsd socket (it does by default)
then it writes to it at startup.

-- 
Simo Sorce * Red Hat, Inc. * New York
