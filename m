From: Fabian Steiner <lists-A1xC5SIKT5unwkN7LPkuEg@public.gmane.org>
Subject: Re: [NFS] Attempting to mount a large number of directories
Date: Mon, 7 Jan 2008 22:28:58 +0100
Message-ID: <200801072228.58507.lists@fabis-site.net>
References: <200712241200.08410.lists@fabis-site.net> <1199695504.3156.69.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Ian Kent <raven@themaw.net>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zucker.schokokeks.org ([85.10.204.247]:58906 "EHLO
	zucker.schokokeks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbYAGV27 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2008 16:28:59 -0500
In-Reply-To: <1199695504.3156.69.camel-J+SFD3YVfrQ/gntp4R1GGQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian Kent wrote:
>> [...]
> I see no-one else wanted to buy into this.
> I'm not really surprised.

Thanks a lot for your explainations! Now it is much easier to understand how 
things work on the low-level area.

> Judging by your attempt to use the insecure option I assume you actually
> know that you're running out of port space on the client. The server, of
> course, consumes only a few ports, like ports for mountd, portmap (or
> rpcbind) and NFS and because it's a server and it reuses the same port
> since the different port used on the client makes the tupple
> clientaddr,clientport,serveraddr,serverport unique. Point is that port
> space is consumed on the client not the server.
>
> So running out of port space is a client problem and the reason it
> happens is that autofs and mount probe to see if the server is up and
> what version of NFS is available etc. before doing the mount. This can
> result in as many a 9 ports consumed for each mount and the ports that
> aren't continuing to be used can't be reused before a timeout has
> passed. I think it's about 60 seconds, and is required for the TCP
> implementation to function properly. So you run out of available ports
> fairly quickly if you issue many mount requests at once.
>
> Quite a bit of work has been done to reduce the port usage over time and
> I think it has been included in recent nfs-utils releases so perhaps a
> later nfs-utils will help.

On the affected machines nfs-utils-1.0.7 has been installed so far. Picking up 
your hint we forced an upgrade from Ubuntu Dapper to Ubuntu Gutsy with 
version 1.1.1~git-20070709 being installed and obviously this solved the 
majority number of problems. Now approx. 400 directories can be mounted. Of 
course, the entire issue requires further investigation; we are quite content 
about the current situation, though.

Fabian


