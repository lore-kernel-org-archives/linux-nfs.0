Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34666 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751738AbeBAP3U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Feb 2018 10:29:20 -0500
Date: Thu, 1 Feb 2018 10:29:18 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@RedHat.com>,
        Naruto Nguyen <narutonguyen2018@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question about random UDP port on rpcbind 0.2.3
Message-ID: <20180201152918.am75vfq776vtj3i3@tonberry.usersys.redhat.com>
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
 <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
 <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
 <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com>
 <27ec9304-5763-9885-b3c9-246c395e6986@RedHat.com>
 <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="irntks7ptu64vvsr"
In-Reply-To: <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--irntks7ptu64vvsr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, 31 Jan 2018, Chuck Lever wrote:

> 
> 
> > On Jan 31, 2018, at 2:57 PM, Steve Dickson <SteveD@RedHat.com> wrote:
> > 
> > 
> > 
> > On 01/31/2018 02:43 PM, Chuck Lever wrote:
> >> 
> >> 
> >>> On Jan 31, 2018, at 2:31 PM, Steve Dickson <SteveD@RedHat.com> wrote:
> >>> 
> >>> 
> >>> 
> >>> On 01/29/2018 01:44 AM, Naruto Nguyen wrote:
> >>>> Hello,
> >>>> 
> >>>> Just would like to add for more information, when I start rpcbind
> >>>> normally, not via systemd, the random UDP is still opened
> >>>> 
> >>>> Could you please share any ideas on this?
> >>> The bound UDP socket is used for remote calls... Where rpcbind
> >>> is asked to make a remote RPC for another caller... 
> >>> 
> >>> Antiquated? yes.. but harmless.
> >> 
> >> Not quite harmless. It can occupy a privileged port that belongs
> >> to a real service.
> > fair enough... 
> > 
> >> 
> >> We should change rpcbind to retain CAP_NET_BIND_SERVICE, so that
> >> it doesn't have to hold onto that port indefinitely. It should
> >> be able to bind to an outgoing privileged port whenever it needs
> >> one.
> > Or we just avoid know ports like sm-notify does.
> 
> statd, you mean. It should also retain CAP_NET_BIND_SERVICE instead
> of what it does now, IMO.
> 
> Note that in both of these cases, that long-lived port is never going
> to be used, going forward: 
> 
> - no one uses the rpcbind port-forward service that I know of
> 
> - NLM is going out of style
> 
> If we can make these two cases on-demand instead, so much the better,
> I say. As Mr. Talpey pointed out recently, the only long-lived
> privileged ports we should see on Linux are well-known service
> listeners, not outgoing ports.

This patch should take care of making rpcbind set up the remote call
port on demand.  I don't have a whole lot of ways to test it though...
just 'rpcinfo -b' and a handful of one-off programs I wrote a while back
trying to mess with the CALLIT/INDIRECT/BCAST procedures.

I'd still need to add the stuff to retain CAP_NET_BIND_SERVICE.

I also like the idea of leaving this off by default and adding a
command-line flag to enable it because I'm also not sure if anyone
actually uses it... not to mention there's been at least one CVE in the
past that exploited it (CVE-2015-7236, not sure if there are others).

-Scott
> 
> A fix for rpcbind might be to add a cmd-line flag to enable the
> rpcbind forwarding service, and have the service default to disabled.
> I'm not sure why rpcbind would list an outgoing port in it's portmap
> menu. Are you sure that this is the forwarding reflector port?
> 
> 
> > steved.
> > 
> >> 
> >> 
> >>> steved.
> >>> 
> >>>> 
> >>>> Brs,
> >>>> Bao
> >>>> 
> >>>> On 27 January 2018 at 19:50, Naruto Nguyen <narutonguyen2018@gmail.com> wrote:
> >>>>> I would like to ask you a question regarding the new random UDP port
> >>>>> in rpcbind 0.2.3.
> >>>>> 
> >>>>> In rpcbind 0.2.3, when I start rpcbind (version 0.2.3) through
> >>>>> rpcbind.service, then I do netstat
> >>>>> 
> >>>>> udp        0      0 0.0.0.0:111             0.0.0.0:*
> >>>>>        10408/rpcbind
> >>>>> udp        0      0 0.0.0.0:831             0.0.0.0:*
> >>>>>        10408/rpcbind
> >>>>> udp6       0      0 :::111                  :::*
> >>>>>        10408/rpcbind
> >>>>> udp6       0      0 :::831                  :::*
> >>>>>        10408/rpcbind
> >>>>> 
> >>>>> The rpcbind does not only listen on port 111 but also on a random udp
> >>>>> port "831" in this case, this port is changed every time the rpcbind
> >>>>> service retstarts. And it listens on 0.0.0.0 so it opens a hole on
> >>>>> security. Could you please let me know what this port is for and is
> >>>>> there any way to avoid that like force it listen on a internal
> >>>>> interface rather than on any interfaces like that? I do not see the
> >>>>> random port on rpcbind 0.2.1, not sure why? As the rpcbind is started
> >>>>> from systemd so "-h" option is invalid as the man page says:
> >>>>> 
> >>>>> 
> >>>>>  -h      Specify specific IP addresses to bind to for UDP requests.
> >>>>> This option may be specified multiple times and can be used to
> >>>>> restrict the interfaces rpcbind will respond to.  Note that when
> >>>>> rpcbind is controlled via sys-
> >>>>>            temd's socket activation, the -h option is ignored. In
> >>>>> this case, you need to edit the ListenStream and ListenDgram
> >>>>> definitions in /usr/lib/systemd/system/rpcbind.socket instead.
> >>>>> 
> >>>>> Thanks a lot,
> >>>>> Brs,
> >>>>> Naruto
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>> the body of a message to majordomo@vger.kernel.org
> >>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>> 
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> 
> >> --
> >> Chuck Lever
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--irntks7ptu64vvsr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-rpcbind-create-the-remote-call-plumbing-on-demand.patch"


--irntks7ptu64vvsr--
