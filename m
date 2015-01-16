Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415AbbAPVgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2015 16:36:24 -0500
Date: Fri, 16 Jan 2015 16:36:15 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Paul van der Vlis <paul@vandervlis.nl>
cc: linux-nfs@vger.kernel.org
Subject: Re: Secure NFSv4 mounts and daemons
In-Reply-To: <m9akb5$ig3$1@ger.gmane.org>
Message-ID: <alpine.OSX.2.19.9992.1501161628010.498@planck.local>
References: <54B6F7C1.5040208@zoho.com> <m9akb5$ig3$1@ger.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 16 Jan 2015, Paul van der Vlis wrote:

> Hi Ralph,
>
> Op 15-01-15 om 00:12 schreef Ralph Zack:
> > Hi all,
> >
> > I have a number of NFSv4 shares which should only be accessible after
> > successful authentication, for which reason they are exported with
> > sec=krb5p. However, this method requires the user to obtain a kerberos
> > ticket to access files on the share, which is fine for regular users but
> > causes issues for daemons which are not kerberos-aware.
> >
> > What is the common way to handle this problem? It can hardly be the only
> > solution to patch each service to obtain a ticket at startup. Please
> > correct me if I'm wrong, but I could not find any mechanism besides
> > kerberos that provides encryption and authentication for NFS shares. I'd
> > be fine with authentication on a host level, I mainly want to ensure
> > that only trusted machines can accesses these shares and that all
> > traffic is encrypted. Without the overhead of establishing a VPN
> > connection between client and server, in case anyone was going to
> > suggest that ;)
>
> I've once seen that something like this makes a ticket:
> su -c "echo password | kinit user" user
> But never used it in reality.
>
> Maybe you can ask this question better in the Kerberos mailinglist.
> I think this is not a good solution...
>
> With regards,
> Paul van der Vlis

Wow, looks like kinit /will/ read your password from stdin.  I had no idea.

I've done this with a keytab and cron job running as the
service's user to keep the credential caches for the service's user fresh.
Kinit should be something like `kinit -kt /keyab/file batch/host@realm.com`
Run your jobs more frequently than the ticket expiry time and everything
should be fine.

Ben
