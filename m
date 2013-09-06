Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:61582 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696Ab3IFRP2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 13:15:28 -0400
Date: Fri, 6 Sep 2013 13:15:17 -0400
From: Jim Rees <rees@umich.edu>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130906171517.GA26256@umich.edu>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
 <20130905204536.GB24805@fieldses.org>
 <20130905233449.5eb8bf79@galadriel.home>
 <20130905214002.GD24805@fieldses.org>
 <20130906175721.30082c11@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20130906175721.30082c11@harpe.intellique.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Emmanuel Florac wrote:

  Le Thu, 5 Sep 2013 17:40:02 -0400
  "J. Bruce Fields" <bfields@fieldses.org> écrivait:
  
  > I was asking about the on-the-wire errors and getattr replies here,
  > not the application system calls.
  > 
  
  OK, I've done the dump; I've kept just the last few working calls, then
  the failure calls, and filtered for NFS traffic (there are SSH and
  LACP frames interspersed here). I have absolutely no idea about what's
  going on there :) Any light from the network savvy?

I suggest you filter on port=2049 instead of proto=nfs.
