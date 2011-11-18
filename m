Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26022 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758070Ab1KRRQK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 12:16:10 -0500
Date: Fri, 18 Nov 2011 19:16:05 +0200
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4 mount expires
Message-ID: <00c101cca615$c2e08db6$78be630a@hq.netapp.com>
Content-Type: text/plain;
	charset="utf-8"
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jim Rees" <rees@umich.edu>, "John Hughes" <john@Calva.COM>
Cc: "Jeff Layton" <jlayton@redhat.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So what are they supposed to do without tickets? Crash?

Jim Rees <rees@umich.edu> wrote:

I'm not arguing that the client machine should hang when tickets expire.
I'm arguing that user processes should not hang when tickets expire.  Sorry
if that wasn't clear.
