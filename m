Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp6-g21.free.fr ([212.27.42.6]:52955 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754052Ab3IKPL4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Sep 2013 11:11:56 -0400
Date: Wed, 11 Sep 2013 17:11:45 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity: problem solved
Message-ID: <20130911171145.323f9b9e@harpe.intellique.com>
In-Reply-To: <20130905191800.1c75b2fb@harpe.intellique.com>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Thu, 5 Sep 2013 19:18:00 +0200
Emmanuel Florac <eflorac@intellique.com> écrivait:

> Any hint, idea, etc would be extremely welcome. Even some
> debugging method less painful than digging through huge 
> tcpdumps would be nice :)

I post this answer in the faint hope that it may avoid a long and
painful week of testing to someone else :)

The problem comes from the virtual network adapter "Intel pro 1000"
using the e1000e linux driver. The Intel hardware supports a MTU of
4078 max. On a physical machine, it will fail to set up a greater value
with something like:

# ifconfig eth0 mtu 4079
SIOCSIFMTU: Invalid argument

However the virtual e1000 from VMWare ESX silently accept any value;
then it will mostly work, and fail in mysterious way and only with
certain protocols (such as nfs).

In the case of VMWare virtual machines, using a vmnet3 virtual network
adapter works fine with a mtu of 9000 under NFS. Therefore the problem
is solved.

For the sake of completeness and curiosity, I'll try and see what
happens with a KVM e1000 virtual device.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
