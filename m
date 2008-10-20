From: Steve Dickson <SteveD@redhat.com>
Subject: Re: mount.nfs should support arbitrary option order
Date: Mon, 20 Oct 2008 06:54:58 -0400
Message-ID: <48FC6382.3070904@RedHat.com>
References: <alpine.LNX.1.10.0810182045380.17929@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33892 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbYJTK4m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 06:56:42 -0400
In-Reply-To: <alpine.LNX.1.10.0810182045380.17929-vVwEwcwQeYFPkBl3ERsXe1l1cybopEuJUBSOeVevoDU@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bz https://bugzilla.linux-nfs.org/show_bug.cgi?id=170 has
been opened.. feel free to add yourself the cc list if you
would like to follow its progress.... (assuming there is any ;-) )

steved.


Jan Engelhardt wrote:
> Hi,
> 
> 
> currently it seems that mount.nfs only accepts -o as the last portion:
> 
> 
> # mount.nfs -o foo a:/ /
> usage: mount.nfs remotetarget dir [-rvVwfnsih] [-o nfsoptions]
> options:
>         -r              Mount file system readonly
>         -v              Verbose
>         -V              Print version
>         -w              Mount file system read-write
>         -f              Fake mount, do not actually mount
>         -n              Do not update /etc/mtab
>         -s              Tolerate sloppy mount options rather than fail
>         -h              Print this help
>         nfsoptions      Refer to mount.nfs(8) or nfs(5)
> 
> # mount.nfs  a:/ / -o foo
> mount.nfs: an incorrect mount option was specified
> 
> 
> It would be nice if options can be specified anywhere. Especially
> hard POSIX puts options first.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
