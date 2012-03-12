Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:40711 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756661Ab2CLUYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 16:24:32 -0400
Date: Mon, 12 Mar 2012 16:24:36 -0400
From: Jim Rees <rees@umich.edu>
To: Michael Weiser <M.Weiser@science-computing.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 post-1.2.2 nfs-utils client fails to mount from pre-1.2.3
 nfs-utils server
Message-ID: <20120312202436.GA13407@umich.edu>
References: <20120312200221.GS29573@science-computing.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120312200221.GS29573@science-computing.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Michael Weiser wrote:

  A direct workaround is to set the following options in /etc/krb5.conf of
  client and server:
  
  [libdefaults]
  default_tkt_enctypes = des-cbc-md5
  permitted_enctypes = des-cbc-md5
  
  , add des-cbc-md5 keys to the keytabs of both machines and allow Single
  DES for both machines' principals on the KDC (MS AD 2008r2 in particular
  wants it enabled explicitly). This however not only limits the
  encryption types of session keys but all tickets as well and applies to
  the whole machine not just the NFSv4 service. This has a needlessly high
  security impact on both machines.

Could this go in an appdefaults clause instead?

My guess is not.  I remember having to add allow_weak_crypto to libdefaults
instead of appdefaults.  But I thought I'd ask.

If not, a command line argument to gssd seems reasonable.
