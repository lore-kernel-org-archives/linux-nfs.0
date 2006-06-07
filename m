From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] [PATCH] NFS server does not update mtime on setattr request
Date: Wed, 07 Jun 2006 11:26:24 -0400
Message-ID: <4486F020.3030707@redhat.com>
References: <4485C3FE.5070504@redhat.com> <1149658707.27298.10.camel@localhost> <4486E662.5080900@redhat.com> <20060607151754.GB23954@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>,
	NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932258AbWFGP0k@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060607151754.GB23954@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

J. Bruce Fields wrote:

>On Wed, Jun 07, 2006 at 10:44:50AM -0400, Peter Staubach wrote:
>  
>
>>I saw that wording too and assumed what I think that you assumed.  I
>>assumed that that meant that if the new size is equal to the old size,
>>then nothing should be changed.  However, that does not seem to be how
>>those words are to be interpreted.  They are to be interpreted as "if
>>the new length of the file can be successfully set, then the
>>mtime/ctime should be changed".
>>    
>>
>
>What's the basis for that interpretation?  The language seems extremely
>clear:
>
>	"On successful completion, if the file size is changed, these
>	functions will mark for update the st_ctime and st_mtime fields
>	of the file, and if the file is a regular file, the S_ISUID and
>	S_ISGID bits of the file mode may be cleared."
>
>Why are you concerned about this?  Do you have an actual application
>that breaks?
>

Yes, there is a customer who is quite unhappy that the semantics over Linux
client NFS are different than those of BSD, Solaris, and local file system
access on Linux itself.  The basis for my work is based on a bugzilla from
this customer.

My interpretation is based on looking at the local behavior on Linux, which
changes mtime/ctime even if the file size does not change, and SunOS, which
changes mtime/ctime even if the file size does not change and is very
heavily SUSv3 compliant.

In this case, "changed" does not mean "made different".  It simply means
that the file size is set to the new value.

I would have chosen different words or a different interpretation too,
but all of the evidence suggests that the semantics are as I stated.

    Thanx...

       ps
