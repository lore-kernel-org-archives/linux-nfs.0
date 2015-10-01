Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbbJARzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Oct 2015 13:55:43 -0400
Date: Thu, 1 Oct 2015 13:55:41 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Constantine Peresypkin <pconstantine@gmail.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: Is UNSTABLE ever sent in client writes?
In-Reply-To: <CAOEg9Lr2rcAUC_x0vZqp_n55gT_WXRR_iZzGh_TKtDFdOsqn7Q@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1510011338400.5275@planck.local>
References: <CAOEg9Lo4N3ceJYV0=L-Khrh-oTFZUyTTS=X5acXTg9JKfe2_YA@mail.gmail.com> <alpine.OSX.2.19.9992.1510011325260.5275@planck.local> <CAOEg9Lr2rcAUC_x0vZqp_n55gT_WXRR_iZzGh_TKtDFdOsqn7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 1 Oct 2015, Constantine Peresypkin wrote:

>
> The question is: can I force it to always use unstable? Or how can I debug why FILE_SYNC is always sent in my case?

No, I don't believe you can.  You can use systemtap, or turn up the nfs
debugging.

I don't think FILE_SYNC will always be sent.  It depends upon how you are
doing IO.  What are you using to test?

Try something like this on a mount with wsize=4096.  It should get you four
unstable writes, and eventually a COMMIT:

#define TPATH "/mnt/fedora/tmp/"
#define SIZE 4096*4
#define CHARS "I love when strings are 32 chars"

int main(void *argc) {
    int pos, filp_foo;
    void *foo_addr;

    unlink(TPATH "foo");
    filp_foo = open(TPATH "foo", O_RDWR|O_CREAT, S_IWUSR|S_IRUSR|S_IRGRP|S_IROTH);
    ftruncate(filp_foo, SIZE);
    foo_addr = mmap(NULL, SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, filp_foo, 0);
    for (pos = 0; pos < SIZE; pos += strlen(CHARS))
        strcpy(foo_addr + pos, CHARS);
    close(filp_foo);
}

Ben


>
> On Oct 1, 2015 12:32 PM, "Benjamin Coddington" <bcodding@redhat.com> wrote:
>       On Thu, 1 Oct 2015, Constantine Peresypkin wrote:
>
>       > Tried with various mount options (sync, async)
>       > Looked into source code.
>       > It seems like it will never be sent, client always assumes server can
>       > do FILE_SYNC, and server cannot respond with anything else, if
>       > implemented correctly.
>       > But what we can do if the server is inherently unable to do FILE_SYNC
>       > (eventual consistency, write reorder, etc.)?
>
>       Hi Constantine, my linux client does unstable writes all the time.
>       nfs_pgio_rpcsetup() default stable arg is NFS_UNSTABLE..
>
>       Try doing a write larger than your mount's wsize parameter.
>
>       Ben
>
>
>
