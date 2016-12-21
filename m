Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60468 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752219AbcLUTjn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Dec 2016 14:39:43 -0500
Subject: Re: [PATCH] Fix boot dependency in systemd service file
To: Yann Leprince <y.leprince@fz-juelich.de>
References: <20161220115856.22467-1-y.leprince@fz-juelich.de>
Cc: Libtirpc-devel Mailing List
        <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <a5696486-dd01-eeba-d7ed-13474e57d301@RedHat.com>
Date: Wed, 21 Dec 2016 14:39:41 -0500
MIME-Version: 1.0
In-Reply-To: <20161220115856.22467-1-y.leprince@fz-juelich.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/20/2016 06:58 AM, Yann Leprince wrote:
> From: Yann Leprince <yann.leprince@ylep.fr>
> 
> This fix ensures that a separate /var partition will be mounted before
> rpcbind tries to write its status to /var/run.
> 
> Signed-off-by: Yann Leprince <yann.leprince@ylep.fr>
Committed... thank you!

steved.
> ---
>  systemd/rpcbind.service.in | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> index c173b83..f8cfa9f 100644
> --- a/systemd/rpcbind.service.in
> +++ b/systemd/rpcbind.service.in
> @@ -2,6 +2,7 @@
>  Description=RPC Bind
>  Documentation=man:rpcbind(8)
>  DefaultDependencies=no
> +RequiresMountsFor=@statedir@
> 
>  # Make sure we use the IP addresses listed for
>  # rpcbind.socket, no matter how this unit is started.
> --
> 2.11.0
> 
> 
> 
> ------------------------------------------------------------------------------------------------
> ------------------------------------------------------------------------------------------------
> Forschungszentrum Juelich GmbH
> 52425 Juelich
> Sitz der Gesellschaft: Juelich
> Eingetragen im Handelsregister des Amtsgerichts Dueren Nr. HR B 3498
> Vorsitzender des Aufsichtsrats: MinDir Dr. Karl Eugen Huthmacher
> Geschaeftsfuehrung: Prof. Dr.-Ing. Wolfgang Marquardt (Vorsitzender),
> Karsten Beneke (stellv. Vorsitzender), Prof. Dr.-Ing. Harald Bolt,
> Prof. Dr. Sebastian M. Schmidt
> ------------------------------------------------------------------------------------------------
> ------------------------------------------------------------------------------------------------
> 
