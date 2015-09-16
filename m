Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33904 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbbIPNmT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 09:42:19 -0400
Received: by oiev17 with SMTP id v17so126239904oie.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2015 06:42:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55F96DDC.8030101@RedHat.com>
References: <55F6C773.9050007@redhat.com>
	<55F71073.6090102@RedHat.com>
	<20150914183024.GA1277@us.ibm.com>
	<55F86E37.1010108@redhat.com>
	<55F96DDC.8030101@RedHat.com>
Date: Wed, 16 Sep 2015 09:42:18 -0400
Message-ID: <CAHQdGtTq1LfEr+n82U1zb66xFDxCF0vFmzu6t2dm3sHmvO0SAQ@mail.gmail.com>
Subject: Re: [Nfs-ganesha-devel] Default ports to be used by NFS side-band
 protocol services (lockd, statd, rquotad)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Soumya Koduri <skoduri@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "nfs-ganesha-devel@lists.sourceforge.net"
	<nfs-ganesha-devel@lists.sourceforge.net>,
        Bruce Fields <bfields@redhat.com>, Niels de Vos <ndevos@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 16, 2015 at 9:25 AM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
>
> On 09/15/2015 03:15 PM, Soumya Koduri wrote:
> >
> >
> > On 09/15/2015 12:00 AM, Malahal Naineni wrote:
> >> Steve Dickson [SteveD@redhat.com] wrote:
> >>> Hello,
> >>>
> >>> On 09/14/2015 09:11 AM, Soumya Koduri wrote:
> >>>> Hi,
> >>>>
> >>>> In the latest Linux distributions (Fedora), ports 2049 (nfs) and 20048 (mountd) are configured to be opened by default by firewalld service.
> >>>>
> >>>> Files: '/usr/lib/firewalld/services/nfs.xml' & '/usr/lib/firewalld/services/mountd.xml'.
> >>> Hmm... I didn't know about this... We should probably
> >>> set the -p 20048 by default via /etc/sysconfig/nfs file or maybe the systemd script?
> >>
> >> I believe, mountd already uses /etc/services file by default. So
> >> specifying it in /etc/services would be good. I think RHEL7 has one for
> >> mountd. This is specific to NFSv3 anyway...
> >>
> >
> > From '/etc/services' & [1], looks like port# '20048' has been registered to be used by mountd service. Does it help if we have ports registered for other services too then? Or is it better to keep them dynamic and leave it to admin to choose & edit '/etc/sysconfig/nfs' file as required.
> >
> > [1] http://www.iana.org/assignments/port-numbers
> >
>
> I'm thinking its better to leave it up to the admins...
>

If that is the case, is there any way to tie the ports assigned to
/etc/sysconfig/nfs etc to a set of firewall rules that open those
ports for incoming traffic? Having to adjust 2 sets of configurations
every time you want to assign a new port is a potential source of
errors.

Trond
