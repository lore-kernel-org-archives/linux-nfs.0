From: "Dilip Kumar" <udilipkumar@gmail.com>
Subject: Re: Bug in NFSV3 ACCESS Procedure reply
Date: Thu, 28 Aug 2008 14:22:35 -0700
Message-ID: <9344d2ec0808281422v13ed6af9gc0f91569d52ca3be@mail.gmail.com>
References: <9344d2ec0808271241x375a4d86r6cfa7c10beb905c8@mail.gmail.com>
	 <20080828173424.GA3529@fieldses.org>
	 <9344d2ec0808281041w15e2738ew546531398f80a312@mail.gmail.com>
	 <20080828174917.GC3529@fieldses.org>
	 <9344d2ec0808281052s71efeeebh81fea6805b6eef10@mail.gmail.com>
	 <20080828185425.GA6146@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:57238 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYH1VWh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2008 17:22:37 -0400
Received: by fg-out-1718.google.com with SMTP id 19so364409fgg.17
        for <linux-nfs@vger.kernel.org>; Thu, 28 Aug 2008 14:22:35 -0700 (PDT)
In-Reply-To: <20080828185425.GA6146@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was writing some scripts to map the Unix access modes to the access
flags in the NFS ACCESS Reply. I have run these scripts on Linux and
Solaris machines and the results were not the same. If I have some C
program which opens this directory in a write mode exported by an NFS
server it succeeds, if the server is Solaris, but fails if the server
is Linux. If I have write access on the directory, I would expect to
see write bit set for that directory in the ACCESS reply. Programs
like mkdir or cd require execute and write access to complete their
operations, but a normal open with write mode should succeed in either
case. I was more concerned about the differences in the implementation
of ACCESS in two different servers.

Thanks
Dilip Kumar

On Thu, Aug 28, 2008 at 11:54 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Aug 28, 2008 at 10:52:07AM -0700, Dilip Kumar wrote:
>> Do you see this issue on your version too? Not sure if there is a
>> patch already addressing this issue.
>
> Hm.  It looks like it may just be this:
>
> static struct accessmap nfs3_diraccess[] = {
>    {   NFS3_ACCESS_READ,       MAY_READ                        },
>    {   NFS3_ACCESS_LOOKUP,     MAY_EXEC                        },
>    {   NFS3_ACCESS_MODIFY,     MAY_EXEC|MAY_WRITE|MAY_TRUNC    },
>    {   NFS3_ACCESS_EXTEND,     MAY_EXEC|MAY_WRITE              },
>    {   NFS3_ACCESS_DELETE,     MAY_REMOVE                      },
>
>    {   0,                      0                               }
> };
>
> So it doesn't claim write is allowed unless exec is also allowed.
>
> I think that's actually how the local filesystem behaves--is there
> any operation you can do locally with only write permissions?
>
> Why is this behavior a problem for you, anyway?
>
> --b.
>
