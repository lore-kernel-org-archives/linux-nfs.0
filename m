From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch 0/9] NFS Mount Configuration File
Date: Mon, 9 Mar 2009 17:49:13 -0400
Message-ID: <A359B7ED-198B-4C3E-96B1-F4B2D5D3582B@oracle.com>
References: <49B57FB2.9020000@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49B57FB2.9020000@RedHat.com>
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

Hi Steve-

On Mar 9, 2009, at Mar 9, 2009, 4:44 PM, Steve Dickson wrote:
> Hello,
>
> The following patch set introduces a configuration file where
> mount options can be define. The options in the file can be
> applied globally or per server or per mount point.
>
> The patch set reuses the configuration parsing code that
> idmapd uses. I did added a couple enhancements like ignoring
> blanks in certain definitions as well as at the beginning of
> assignment statements.
>
> There are man pages include in the patch set but in a
> nut shell, the configuration file has three basic types
> of sections. A global section, server section and mount point
> section. There can only be one global section and multiple
> server and mount point sections.
>
> The mount command prioritize these sections in the following
> way:
>     * Options on the command line are always used.
>
>     * Options defined in the mount point section are used
>       as long a the options are not in the command line options.
>
>     * Options defined in the server section are used as long as
>       they are not defined on the command line or in the mount point
>       section.
>
>     * Options defined in the global section are used as long as the
>       options are not on the command line or in the mount point  
> section
>       or in the server section.

This can become challenging to troubleshoot if there are these semi- 
hidden options (cf. selinux).

I don't get why the per-mount section is even needed -- currently, the  
mount options in /etc/fstab are used automatically if no options are  
specified on the command line.

Is there a specific use case you have in mind for the per-mount  
section?  You just want a user to say "-o noac" and she will get all  
the remaining options in the per-mount section too?  I guess that  
means you also need to know when to specify the opposite to turn off  
the options listed in this section (like using "-o ac" if noac is  
contained in this section).  So again, that doesn't seem like  
especially helpful behavior in some cases.

This scheme doesn't allow conditional options: "always use retrans=10  
if proto=udp was specified, but retrans=2 if proto=tcp was specified."

> This is the first step toward moving the default NFS version from 3  
> to 4
> on the client.

I would think that the _only_ step is to implement the version  
fallback logic; ie. if the server doesn't support NFSv4, then use  
NFSv3, then NFSv2.  Why can't an admin simply specify a fixed NFS  
version (nfsvers=3) if there is a problem with NFSv4?  It seems to me  
that if the admin hasn't specified nfsvers=, then she does not care  
which NFS version is used.

> Having a configuration file which allows users to define
> the maximum and minimum NFS versions that should be negotiated is the
> right thing to do... IMHO.. Even though this patch does not does not
> do that, it does lay the ground work for that type of functionality.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
