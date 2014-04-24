Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54121 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbaDXDM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2014 23:12:26 -0400
Date: Wed, 23 Apr 2014 23:12:16 -0400
From: Jim Rees <rees@umich.edu>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Tuning Linux NFSv4 for high latency connections?
Message-ID: <20140424031216.GA18817@umich.edu>
References: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALXu0UcdfrvCajbAagGLV=dP=Kk3VWeR4VS5Wna44UroxM4JAQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cedric Blancher wrote:

  Are there any options to improve the Linux NFSv4 performance over a
  high latency connection?

We did some work along these lines at CITI years ago. As I remember, the
main thing was to increase net.ipv4.tcp_[rw]mem on the server side, because
tcp auto-tuning was being defeated. This may be less of an issue with your
work load, which sounds like many small files rather than one big one.  In
theory, NFSv4 delegations should help, but I don't know how well that works.
