Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:33373
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288Ab3JGRtl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Oct 2013 13:49:41 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Mkrtchyan, Tigran'" <tigran.mkrtchyan@desy.de>
Cc: "'J. Bruce Fields'" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
References: <1381004835-7485-1-git-send-email-tigran.mkrtchyan@desy.de> <20131007150507.GE18051@fieldses.org> <00e001cec377$0e814340$2b83c9c0$@mindspring.com> <1832028240.530852.1381167926616.JavaMail.zimbra@desy.de>
In-Reply-To: <1832028240.530852.1381167926616.JavaMail.zimbra@desy.de>
Subject: RE: [PATCH] pynfs: fix reporting of ignored tests
Date: Mon, 7 Oct 2013 10:48:26 -0700
Message-ID: <00e501cec385$7c97c170$75c74450$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > Tigran,
> >
> Hi Frank,
> 
> > You also modified DSESS9005, should that actually be split into two
> > separate test cases?
> 
> I was thinking to add one with compound: SEQ, PUTROOTFH,
> DESTROY_SESSION

Yea, that would be good.

Frank


