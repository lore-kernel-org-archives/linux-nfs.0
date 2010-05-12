Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:57302 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758527Ab0ELXVD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 19:21:03 -0400
Received: by ywh36 with SMTP id 36so292048ywh.4
        for <linux-nfs@vger.kernel.org>; Wed, 12 May 2010 16:21:02 -0700 (PDT)
In-Reply-To: <4BEB1FA2.1060001@inria.fr>
References: <4BCFE979.2000406@inria.fr> <4BE1E099.9050902@inria.fr>
	 <4BEB1FA2.1060001@inria.fr>
Date: Wed, 12 May 2010 19:21:01 -0400
Message-ID: <AANLkTinNTYrEe9G6urXBxv-hogZPatOe9zWbbjnVTbWz@mail.gmail.com>
Subject: Re: trouble using kerberos between linux client and server
From: Kevin Coffman <kwc@citi.umich.edu>
To: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 12, 2010 at 5:37 PM, Guillaume Rousse
<Guillaume.Rousse@inria.fr> wrote:
> Le 05/05/2010 23:18, Guillaume Rousse a écrit :
>> I'm attaching network capture, even I can't figure additional
>> information from it by myself.
> Reading https://bugzilla.redhat.com/show_bug.cgi?id=562807, I rebuild
> libtirpc with patch applied and -DDEBUG. Unfortunatly, it doesn't bring
> additional information about the server-side failure :(

It looks to me like fflush(), called in qword_eol(), may be returning
the number of bytes flushed (95) rather than zero for success?  I
don't immediately see any changes that would cause this.  But I
haven't looked extensively...

K.C.
