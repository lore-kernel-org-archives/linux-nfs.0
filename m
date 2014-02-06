Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3-phx2.redhat.com ([209.132.183.24]:60018 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755949AbaBFMPP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 07:15:15 -0500
Date: Thu, 6 Feb 2014 07:15:10 -0500 (EST)
From: Simo Sorce <ssorce@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Message-ID: <1159251059.5418996.1391688910525.JavaMail.root@redhat.com>
In-Reply-To: <20140206122751.41b2fbf9@notabene.brown>
References: <20140130172451.7a354ce4@notabene.brown> <52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown> <20140204162052.GA5295@fieldses.org> <20140205140906.0b3ba9fd@notabene.brown> <1B2F95A4-8439-4274-A859-F33986D06824@oracle.com> <20140206122751.41b2fbf9@notabene.brown>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> On Wed, 5 Feb 2014 10:56:39 -0500 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > Hi Neil!
> > 
> > 
> > On Feb 4, 2014, at 10:09 PM, NeilBrown <neilb@suse.de> wrote:
> > 
> > > On Tue, 4 Feb 2014 11:20:52 -0500 "J. Bruce Fields"
> > > <bfields@fieldses.org>
> > > wrote:
> > > 
> > >> On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
> > >>> Also, I've been wondering if we could avoid the need to explicitly
> > >>> enable
> > >>> the gss stuff by gating it on the existence of /etc/krb5.keytab.
> > >>> Do you think that would be reasonable?
> > >> 
> > >> That would be great.  I hate that people have to care about these
> > >> support daemons, they should just be started automatically when they're
> > >> needed.
> > >> 
> > >> Is /etc/krb5.keytab the best indicator?
> > > 
> > > I was hoping you would tell me. :-)
> > 
> > rpc.gssd has to run in cases where there is no /etc/krb5.keytab.  Remember
> > the discussion we had last year about using root’s user credential as the
> > client’s machine credential?  We want the kernel to be able to find out
> > whether there is a machine credential available, and one can be available
> > even if there is no keytab.
> 
> Hi Chuck,
>  thanks for reminding me about that!  Yes we clearly cannot key
>  off /etc/krb5.keytab for rpc.gssd.
> 
>  Maybe /etc/krb5.conf?  Seems a bit lame.
>  How about  /etc/gssapi_mech.conf ??  rpc.gssd seems to exit if that doesn't
>  exist.  What if systemd is told not to run rpc.gssd if that file is
>  missing?

-1
 
>  I guess that otherwise we can make it on-by-default, but document that
>  people
>  can turn it off with
>      systemctl mask rpc-gssd

big +1

>  which is probably easier that requiring "systemctl enable nfs-secure".

I would really like to see nfs-secure go away, it is a "configuration option" not some entity you start anyway so it never made sense to me.

Simo.

-- 
Simo Sorce * Red Hat, Inc. * New York
