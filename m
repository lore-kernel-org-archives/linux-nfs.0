From: Andy Adamson <andros@netapp.com>
Subject: Re: 4.1 client - LAYOUTCOMMIT & close
Date: Fri, 2 Jul 2010 11:41:12 -0400
Message-ID: <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: <linux-nfs@vger.kernel.org>, <bhalevy@panasas.com>
To: Sandeep Joshi <sjoshi-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4266 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755703Ab0GBPlP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Jul 2010 11:41:15 -0400
In-Reply-To: <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE-e1HlL03umel79urLq6li5IWksG4c/lV9Sp/tIRYA5EM@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 1, 2010, at 8:07 PM, Sandeep Joshi wrote:

Hi Sandeep

>
> In certain cases, I don't see layoutcommit on a file at all even  
> after doing many writes.

FYI:

You should not be paying attention to layoutcommits  - they have no  
value for the file layout type.

 From RFC 5661:

"The LAYOUTCOMMIT operation commits chages in the layout represented  
by the current filehandle, client ID (derived from the session ID in  
the preceding SEQUENCE operation), byte-range, and stateid."

For the block layout type, this sentence has meaning in that there is  
a layoutupdate4 payload that enumerates the blocks that have changed  
state from being 'handed out' to being 'written'.

The file layout type has no layoutupdate4 payload, and the layout does  
not change due to writes, and thus the LAYOUTCOMMIT call is useless.

The only field in the LAYOUTCOMMIT4args that might possibly be useful  
is the loca_last_write_offset which tells the server what the client  
thinks is the EOF of the file after WRITE. It is an extremely lame  
server (file layout type server) that depends upon clients for this  
info.

>
>
>
> Client side operations:
>
> open
> write(s)
> close
>
>
> On server side (observed operations):
>
> open
> layoutget's
> close
>
>
> But, I do not see laycommit at all. In terms data written by client  
> it is about 4-5MB.
>
> When does client issue laycommit?

The latest linux client sends a layout commit when the VFS does a  
super_operations.write_inode call which happens when the metadata of  
an inode needs updating. We are seriously considering removing the  
layoutcommit call from the file layout client.

-->Andy

>
>
> regards,
>
> Sandeep
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

