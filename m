From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS: unknown mount option: grpid
Date: Thu, 10 Apr 2008 12:07:46 -0400
Message-ID: <47FE3B52.5060907@RedHat.com>
References: <47FE0C42.6030900@TechFak.Uni-Bielefeld.DE>
	<56D1CF7A-BB26-4D07-B47D-9D43D55A1B8F@oracle.com>
	<47FE2C2D.1070703@redhat.com>
	<A5A48540-EC83-422F-A566-324A5F141339@oracle.com>
	<20080410153449.GA9429@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Jan Sanders <jsanders@TechFak.Uni-Bielefeld.DE>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080410153449.GA9429@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
>>>>> The mount call returns with EINVAL invalis argument.
>>>>>
>>>>>  From strace:
>>>>> mount("nfs-server:/volumes/www", "/vol/www", "nfs", MS_NOSUID,
>>>>> "grpid,addr=192.168.0.123") = -1 EINVAL (Invalid argument)
>>>>>
>>
>> However, I was not aware of a requirement for NFS mount to ignore all  
>> options it doesn't understand.
>>
>> It's easy enough to add, I suppose.  Community opinion?
> 
> This is exactly what "-s" ("sloppy") is supposed to do, right?  At
> least, that's what "man mount" says.
Not exactly... Looking at the code it seems '-s' will cause the mount.nfs 
command to ignore unknown _nfs_ options. In this case it appears the
sys_mount call is failing which something different.

steved.
