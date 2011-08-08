From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: Unable to Compile Latest Kernel from Git
Date: Mon, 8 Aug 2011 15:01:43 -0400
Message-ID: <CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com>
References: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Billy Hass <billdh16@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:58275 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab1HHTBo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 15:01:44 -0400
Received: by gwaa12 with SMTP id a12so805343gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 08 Aug 2011 12:01:44 -0700 (PDT)
In-Reply-To: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd like to 2nd this.

Current pnfs server doesn't build if chosen to be build into the
kernel. It does build, if built as a module.

when client and server code is build into the kernel it seems that
both sides try to define pnfs_roc() function and stepping on each
others toes..

On Fri, Aug 5, 2011 at 9:58 PM, Billy Hass <billdh16@gmail.com> wrote:
> Hey all,
>
> I am unable to compile the latest kernel from the git tree.
>
> git clone git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git
> cd linux-pnfs
> make oldconfig
> make -j5 -s
> =A0=A0=A0=A0 [ ... ]
> =A0=A0=A0=A0 [A lot of warnings, but no errors]
> =A0=A0=A0=A0 [ ... ]
> make install
> =A0=A0=A0=A0 sh /usr/src/kernels/3.0.0/linux-
> =A0 =A0 pnfs/arch/x86/boot/install.sh 3.0.0-pnfs arch/x86/boot/bzImag=
e \
> =A0=A0 =A0 =A0 =A0 System.map "/boot"
> =A0 =A0 =A0 *** Missing file: arch/x86/boot/bzImage
> =A0=A0=A0=A0=A0 *** You need to run "make" before "make install".
> =A0=A0=A0=A0 make[1]: *** [install] Error 1
> =A0=A0=A0=A0 make: *** [install] Error 2
>
> When I try to do the make again, here is the output
> make -j5 -s
> =A0=A0=A0=A0 fs/nfsd/built-in.o: In function `pnfs_roc':
> =A0=A0=A0=A0 (.text+0x226d1): multiple definition of `pnfs_roc'
> =A0=A0=A0=A0 fs/nfs/built-in.o:(.text+0x304ee): first defined here
> =A0=A0=A0=A0 make[1]: *** [fs/built-in.o] Error 1
> =A0=A0=A0=A0 make: *** [fs] Error 2
> =A0=A0=A0=A0 make: *** Waiting for unfinished jobs....
>
> Thanks for any help!
>
> Bill
>
> --
> Bill D. Hass
> Major | Electrical Engineering BSE
> Minor | Mathematics
> University of Michigan '13
> College of Engineering
> (715) 923-8382
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
