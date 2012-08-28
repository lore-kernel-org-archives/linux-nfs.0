Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:58174 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351Ab2H1Rna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 13:43:30 -0400
Date: Tue, 28 Aug 2012 13:43:14 -0400
From: Jim Rees <rees@umich.edu>
To: Frank Nicholas <frank@nicholasfamilycentral.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: kernel BUG at fs/nfs/idmap.c:684!
Message-ID: <20120828174314.GA2202@umich.edu>
References: <DE540E0D-0D1E-45CE-9968-DA9950497B07@nicholasfamilycentral.com>
 <0DDD46E4-9D32-4BA4-8BD8-22F347FC9E9B@nicholasfamilycentral.com>
 <503CD925.7050000@netapp.com>
 <F5B43205-C11E-4ED7-A530-DCE49B911BE6@nicholasfamilycentral.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F5B43205-C11E-4ED7-A530-DCE49B911BE6@nicholasfamilycentral.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank Nicholas wrote:

  Thanks for the quick reply.
  
  The patches applied cleanly.  I've rebuilt my kernel.  The reboot will
  have to wait until I have physical access to the machine to do a hard
  power off…  Unless you know of some way to clean up the hung NFS items so
  I can do a reboot.  Currently if I try a 'shutdown -r now', the system
  hangs on trying to clean up the NFS items.

Did you try "reboot -f"?
