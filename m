From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] idmapd: Fix decoding of octal encoded fields.
Date: Wed, 21 Sep 2011 15:40:08 -0400
Message-ID: <4E7A3D98.1010405@RedHat.com>
References: <alpine.DEB.2.02.1109201952540.26882@users.fbihome.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Jan-Marek Glogowski <glogow-iG8UcmBuX++ELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab1IUTkO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 15:40:14 -0400
In-Reply-To: <alpine.DEB.2.02.1109201952540.26882-icXI/ei3vljFQw+nKBmkQg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/20/2011 02:14 PM, Jan-Marek Glogowski wrote:
> The decoded octal will always be positive and (char) -1 is negative. Any field containing an encoded octal will be rejected.
> 
> As the encoded value should be an unsigned char, fix the check to reject all values > (unsigned char) -1 = UCHAR_MAX, as this indicate an error in the encoding.
> 
> Signed-off-by: Jan-Marek Glogowski <glogow-iG8UcmBuX++ELgA04lAiVw@public.gmane.org>
Committed..

steved.

> 
> --- nfs-utils-1.2.4.orig/utils/idmapd/idmapd.c
> +++ nfs-utils-1.2.4/utils/idmapd/idmapd.c
> @@ -925,9 +925,9 @@ getfield(char **bpp, char *fld, size_t f
>          if (*bp == '\\') {
>              if ((n = sscanf(bp, "\\%03o", &val)) != 1)
>                  return (-1);
> -            if (val > (char)-1)
> +            if (val > UCHAR_MAX)
>                  return (-1);
> -            *fld++ = (char)val;
> +            *fld++ = val;
>              bp += 4;
>          } else {
>              *fld++ = *bp;
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
