Return-Path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <200910051909.37910.agruen@suse.de>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>
	<200910051831.56157.agruen@suse.de>
	<524f69650910050944k9bd0a3ci7b728f13b2c8225b@mail.gmail.com>
	<200910051909.37910.agruen@suse.de>
Date: Mon, 5 Oct 2009 12:19:05 -0500
Message-ID: <524f69650910051019l49f09166v25f2288ddb30a92f@mail.gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
From: Steve French <smfrench@gmail.com>
To: Andreas Gruenbacher <agruen@suse.de>
Cc: ffilzlnx@linux.vnet.ibm.com, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>, nfsv4@linux-nfs.org,
        jra@samba.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 5, 2009 at 12:09 PM, Andreas Gruenbacher <agruen@suse.de> wrote:
> On Monday 05 October 2009 18:44:34 Steve French wrote:
>> Recently I looked through NFSv4.1 spec, and it seems to address some
>> ACL incompatibilities (with CIFS) by extending the NFSv4 ACL model.
>>
>> Should we be aiming for an eventual interface that would work for NFSv4.1
>> or limiting it to current NFSv4?
>
> I think Automatic Inheritance [*] is important for current Windows clients:
> without it it's basically impossible to manage the permissions of entire
> directory trees without shooting yourself in the foot.

Yes - that piece among the various NFSv41 ACL changes also
jumped out to me as I scanned the NFSv4.1 summary ... in part
because I was looking at some Samba mapping problems (CIFS to NFSv4
ACLs) recently.   In any case, seems very useful (even without
any CIFS compatibility issues).


-- 
Thanks,

Steve
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
