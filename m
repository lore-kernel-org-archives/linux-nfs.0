Return-Path: <SRS0=VKO3=OY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4010BC43387
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Dec 2018 03:00:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0B9AB2086D
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Dec 2018 03:00:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=csiro.au header.i=@csiro.au header.b="IWBDY2px"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727778AbeLODAe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 22:00:34 -0500
Received: from act-MTAout2.csiro.au ([150.229.7.38]:64610 "EHLO
        act-MTAout2.csiro.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727634AbeLODAe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Dec 2018 22:00:34 -0500
X-Greylist: delayed 594 seconds by postgrey-1.27 at vger.kernel.org; Fri, 14 Dec 2018 22:00:32 EST
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=csiro.au; i=@csiro.au; q=dns/txt; s=dkim;
  t=1544842832; x=1576378832;
  h=date:from:to:subject:message-id:mime-version;
  bh=U5DsCITlkc0/ixI8sADhJHiKC0/2vXegHAVc5toZ46k=;
  b=IWBDY2pxyu6AeKpMHmyr6iFkuf4Jy42zf8Td/bj59DE77lBOGbqYqH/2
   1AlZ6XtsO10rP2w9FaJ9rVSoiZcz1+t4UC9EWqkrdPCs/W6r/TCda2Q7w
   fnuds7NFv8hwWC4WglBs7FnimRi3rR6PiX3PVGZepm+ePmDQoWNgpaDLC
   4=;
X-SBRS: 4.0
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: =?us-ascii?q?A+EoAADOaxRcjACwBSSwhIATAJKcgDR?=
 =?us-ascii?q?kHAEBAQQBAQcEAQGBUgYBAQsBgTCCbJgDmWWBeg0sgxiEMCI1CA0BAwEBAgE?=
 =?us-ascii?q?BAgICEAEBASZYhWsTexUfToM0ggEBpj0zii0JAYw0gVc/gRGIYIUQAqEYBwK?=
 =?us-ascii?q?CKI8nCxiRUoMIllmBSAE0KoEubINBgjSOOiyBOSGLfgGBHgEB?=
X-IPAS-Result: =?us-ascii?q?A+EoAADOaxRcjACwBSSwhIATAJKcgDRkHAEBAQQBAQcEA?=
 =?us-ascii?q?QGBUgYBAQsBgTCCbJgDmWWBeg0sgxiEMCI1CA0BAwEBAgEBAgICEAEBASZYh?=
 =?us-ascii?q?WsTexUfToM0ggEBpj0zii0JAYw0gVc/gRGIYIUQAqEYBwKCKI8nCxiRUoMIl?=
 =?us-ascii?q?lmBSAE0KoEubINBgjSOOiyBOSGLfgGBHgEB?=
Received: from exch4-cdc.nexus.csiro.au ([IPv6:2405:b000:601:13::247:34])
  by act-ironport-int.csiro.au with ESMTP/TLS/AES256-SHA; 15 Dec 2018 13:50:36 +1100
Received: from mayhem.atnf.CSIRO.AU (130.155.194.144) by
 exch4-cdc.nexus.csiro.au (152.83.247.34) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Sat, 15 Dec 2018 13:50:36 +1100
Date:   Sat, 15 Dec 2018 13:50:35 +1100
From:   Vincent McIntyre <vincent.mcintyre@csiro.au>
To:     <linux-nfs@vger.kernel.org>
Subject: mount option timeo - in deciseconds, or seconds?
Message-ID: <20181215025034.j5zyfytvxqt35woz@mayhem.atnf.CSIRO.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
User-Agent: NeoMutt/20170113 (1.7.2)
X-Originating-IP: [130.155.194.144]
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

I've been trying to figure out why the nfs.man manpage states

  .BI timeo= n
  The time in deciseconds (tenths of a second) the NFS client waits for a
  response before it retries an NFS request.

Can someone who actually understands NFS enlighten me?
Here's where I'm up to.

I looked in the upstream git.
The 'deciseconds' has been in there since the start of git history
(2007, commit id 16db99b56a532bf56fa27618a6ef30763cd9006f).
But is it (still) correct?

Unfortunately I can't see a direct use of the 'timeo' field
of the NFS data structure so the answer is not easily found.

In utils/mount/nfsmount.c mountnfs() we have

 timeout = time(NULL) + 60 * retry;

This sets the upper bound for how long to wait for a mount to succeed.
The units are seconds, because retry is given in minutes.

Also we see

 prevt = 0;
 t = 30;
 val = 1;

these are the control variables for the loop
The main check that prolongs the waiting time is

            if (t - prevt < 30)
                sleep(30);
             ....if not mounted yet...
            prevt = t;

The decision to time out is made like this
            t = time(NULL);
            if (t >= timeout) {
                rpc_mount_errors(*nfs_server.hostname, 0, bg);
                goto fail;
            }

so it seems clear that t should also have the units of seconds.
That also matches up with the declaration of t & timeout as time_t.

But I still don't see how data.timo gets used.
utils/mount/network.h defines this

  static const struct timeval TIMEOUT = { 20, 0 };
and
  #define MOUNT_TIMEOUT   (30)

which would seem to be in units of seconds,
since eg. connect_to() uses seconds
which reaches it via the calling path:

1.
 CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
{
...
    *msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, MOUNT_TIMEOUT,
                TRUE, FALSE);

2.
static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
            unsigned int timeout, int resvp, int conn)
{
...
        cc = connect_to(so, SAFE_SOCKADDR(saddr), namelen,
                timeout);
3.
/*
 * Attempt to connect a socket, but time out after "timeout" seconds.
 *
 * On error return, caller closes the socket.
 */
static int connect_to(int fd, struct sockaddr *addr,
            socklen_t addrlen, int timeout)
{


Thanks
Vince
