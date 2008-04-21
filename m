From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 13:25:19 -0400
Message-ID: <24c1515f0804211025q3ae8f9ffk3a4abf20f11dde49@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com>
	 <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org>
	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
	 <24c1515f0804210746t2d392b8ct6575f09dc7254b07@mail.gmail.com>
	 <20080421165903.GB4379@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:59789 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbYDURZV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 13:25:21 -0400
Received: by el-out-1112.google.com with SMTP id n30so469808elf.21
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2008 10:25:20 -0700 (PDT)
In-Reply-To: <20080421165903.GB4379@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2008 at 12:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > So shall we add yet another port option for statd or talk
>  > to portmap about the port assignment?  It's ugly any way
>  > you put it.
>
>  I'm confused--why is either needed?

Right, it wasn't. Let me experiment with the patch
first if it does anything sane..


-- 
// Janne
