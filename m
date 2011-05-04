Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:50033 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750888Ab1EDJXR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2011 05:23:17 -0400
From: Roberto Sassu <roberto.sassu@polito.it>
To: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC][PATCH 0/7] File descriptor labeling
Date: Wed, 4 May 2011 11:19:57 +0200
Cc: Tyler Hicks <tyhicks@linux.vnet.ibm.com>,
        linux-security-module@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com, jmorris@namei.org,
        zohar@linux.vnet.ibm.com, safford@watson.ibm.com,
        kirkland@canonical.com, ecryptfs-devel@lists.launchpad.net,
        eparis@redhat.com, sds@tycho.nsa.gov, selinux@tycho.nsa.gov,
        viro@zeniv.linux.org.uk, john.johansen@canonical.com,
        apparmor@lists.ubuntu.com, bfields@fieldses.org, neilb@suse.de,
        linux-nfs@vger.kernel.org
References: <201104291139.37489.roberto.sassu@polito.it> <201105021053.54031.roberto.sassu@polito.it> <4DC088A8.4000300@schaufler-ca.com>
In-Reply-To: <4DC088A8.4000300@schaufler-ca.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201105041119.57493.roberto.sassu@polito.it>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday, May 04, 2011 12:58:48 AM Casey Schaufler wrote:
> On 5/2/2011 1:53 AM, Roberto Sassu wrote:
> > On Friday, April 29, 2011 05:46:20 PM Casey Schaufler wrote:
> >> On 4/29/2011 2:39 AM, Roberto Sassu wrote:
> >>> Sorry for resending, it was rejected by the mailing lists due to
> >>> the html formatting.
> >>>
> >>>
> >>> On Thursday, April 28, 2011 07:37:29 PM Casey Schaufler wrote:
> >>>> On 4/28/2011 5:35 AM, Roberto Sassu wrote:
> >>>>> On Thursday, April 28, 2011 01:27:19 AM Tyler Hicks wrote:
> >>>>>> On Wed Apr 27, 2011 at 01:19:55PM -0700, Casey Schaufler <casey@schaufler-ca.com> wrote:
> >>>>>>> On 4/27/2011 5:34 AM, Roberto Sassu wrote:
> >>>>>>>> File descriptor labeling issue
> >>>>>>>>
> >>>>>>>> Actually SELinux and SMACK assign to file descriptors the same label of the
> >>>>>>>> opening process and use it in LSM hooks security_file_permission(),
> >>>>>>>> security_file_fcntl() and others to verify if the 'current' process has the
> >>>>>>>> rights to perform the requested operation.
> >>>>>>>>
> >>>>>>>> Using the credentials of the 'current' process may be not appropriate in
> >>>>>>>> case a file descriptor is opened by a kernel service (i.e. a filesystem)
> >>>>>>>> and made shared among user processes. For instance, in a system with
> >>>>>>>> SELinux and eCryptfs, if the process A opens an encrypted file, eCryptfs
> >>>>>>>> obtains a file descriptor to access the correspondent inode in the lower
> >>>>>>>> filesystem, labeled with the A's label.
> >>>>>>>>
> >>>>>>>> If the process B accesses the same encrypted file, it needs the 'use'
> >>>>>>>> permission on the A's label other than permissions for the lower inode.
> >>>>>>>> However, if B is the first accessing process, A needs the 'use' permission
> >>>>>>>> on the B's label.
> >>>>>>> I am having trouble understanding the argument. I will pose my
> >>>>>>> question in Smack terms, as I can speak most definitively in them.
> >>>>>>>
> >>>>>>> A process running with a Smack label "A" creates a file, and that
> >>>>>>> file gets labeled "A", as it ought. If eCryptfs is behaving correctly
> >>>>>>> this ought not change. If eCryptfs in encrypting the label it needs
> >>>>>>> to do so in such a way as to be able to decrypt it prior to
> >>>>>>> presentation to the vfs layer, where it will be used in an access
> >>>>>>> check. When the process running with a Smack label "B" comes along
> >>>>>>> the vfs code will check the fetched and possibly decrypted "A"
> >>>>>>> against "B" and, unless there is an explicit Smack rule in place
> >>>>>>> granting "B" access to "A", fail.
> >>>>>>>
> >>>>>>> What is the problem? What is eCryptfs doing that prevents this
> >>>>>>> from working?
> >>>>>> Hi Casey - I think what Roberto is getting at is the way eCryptfs uses
> >>>>>> only one lower file per eCryptfs inode. Imagine that there are 5
> >>>>>> files open for ~/secret/foo at the eCryptfs layer, only 1 file is going
> >>>>>> to be open in the lower filesystem and all eCryptfs file operations will
> >>>>>> be multiplexed through it.
> >>>>>>
> >>>>>> To make things more complicated, if the eCryptfs file is opened for
> >>>>>> writing, the lower file must be opened for reading and writing. This is
> >>>>>> because a write operation requires eCryptfs to vfs_read() from the lower
> >>>>>> filesystem, decrypt that data and then vfs_write() the new data.
> >>>>>>
> >>>>>> If the lower file can't be opened O_RDWR by the calling process, the
> >>>>>> request is handed off to a kernel thread to open the lower file on
> >>>>>> behalf of the calling process. It is definitely ugly.
> >>>>>>
> >>>>>> Roberto, I hope I correctly described the situation that you're trying
> >>>>>> to address. Can you tell me why we can't have a 1:1 mapping of eCryptfs
> >>>>>> files to lower files?
> >>>>>>
> >>>>>> Instead of having just one lower file attached to the eCryptfs inode, we
> >>>>>> could have a list of opened files. There would be one for each eCryptfs
> >>>>>> file that was opened. ecryptfs_writepage() would have to pick, in a
> >>>>>> somewhat random fashion, one of the lower files to use. Of course, we
> >>>>>> would still need to solve the problem of opening the lower file O_RDWR
> >>>>>> when the calling process is only allowed write access (I may have just
> >>>>>> answered my own question of why the 1:1 mapping technique won't solve
> >>>>>> this problem).
> >>>>>>
> >>>>> Hi Tyler
> >>>>>
> >>>>> i think the 1:1 mapping isn't necessary at least from the security perspective.
> >>>>> Since eCryptfs is a stacked filesystem access control is performed on
> >>>>> both the upper and the lower layer.
> >>>>> ECryptfs relies on the lower filesystem for the management of extended
> >>>>> attributes, so this means that the security label of both the upper and
> >>>>> the lower inodes is the same (however this is not the current behavior
> >>>>> in SELinux, which assigns the label 'ecryptfs_t' to the upper inode).
> >>>> Where does this assignment occur?
> >>>>
> >>> Hi Casey
> >>>
> >>> The assignment happens at the inode's initialization time and depends on
> >>> the behavior configured for a specific filesystem.
> >>> The SELinux reference policy actually configures static labeling for inodes
> >>> in the eCryptfs filesystem while for example allows ext4 inodes to be
> >>> initialized using extended attributes.
> >> So how about changing eCryptfs (Goodness, but I hate camelCase) to
> >> properly support extended attributes? That would seem a better
> >> approach than mucking up the entire LSM. You still have to deal
> >> with the SELinux policy, but I don't see you getting away without
> >> doing something with that in any case.
> >>
> > Hi Casey
> >
> > i think having separate extended attributes in eCryptfs does not
> > address the issue i reported in the cover letter.
> > The reason is, in my opinion, the incorrect labeling of file descriptors
> > which causes in SELinux more permissions than those really needed
> > must be added in the policy. This does not depends on the inode's
> > security context but on the credentials provided to dentry_open().
> 
> The problem is that you seem to think that eCryptfs needs
> access to the file. If eCryptfs is kernel code being invoked
> through the VFS you should be providing the user's credentials.
> 
> >
> >>>>> In my view, for this reason the access control checks can be performed
> >>>>> only at the upper layer, letting eCryptfs full privileges to access inodes
> >>>>> in the lower filesystem.
> >>>> On this point I most strongly disagree.
> >>>>
> >>>> The behavior of a filesystem and the data that it uses to determine
> >>>> that behavior is wrought with complex interactions which may include
> >>>> but are not limited to caching, read-aheads, garbage collection,
> >>>> and various side effects of access control. If eCryptfs needs to go
> >>>> mucking about with the data used by the underlying filesystem it is
> >>>> not stacking properly. A stacked filesystem has no business whatever
> >>>> changing the data of the underlying filesystem.
> >>>>
> >>> Ok, probably i have to go more in deep to explain how access control is
> >>> performed on eCryptfs. I'm talking for the SELinux's case, so SELinux experts
> >>> can correct me if i'm wrong.
> >>>
> >>> First, i want to use extended attributes to initialize an eCryptfs inode, so
> >>> both the upper and the lower inodes have the same security context
> >>> because eCryptfs calls the *xattr() methods of the underlying filesystem.
> >> OK, you could create your own xattr functions that do whatever credential
> >> mucking they need to and then call the underlying file system's version.
> >> It is possible that the work the NFS people have been doing for xattr
> >> support (I haven't seen much on this lately, is it still active? Anyone?)
> >> would prove instructive.
> >>
> >>> Then, the process A accesses the eCryptfs inode 'I'. On the upper layer access
> >>> control is performed using the credentials of the 'current' process and the
> >>> security context of I.
> >>>
> >>> If the process is allowed to access the upper inode, eCryptfs opens the lower
> >>> inode, presenting its own credentials with the type 'kernel_t'.
> >> So eCryptfs provides its own process context. When you say "open" do you
> >> mean open(2) or something else? A little precision goes a long way in these
> >> discussions.
> >>
> > ECryptfs provides its own credentials when calling the function dentry_open()
> > to obtain a file descriptor to be shared among user processes.
> 
> This is your problem. The problem is that you are not
> using the credential of the user process to access the
> file, you are using your own. Sharing a "file descriptor"
> may seem like an optimization, but as you see it has
> does not work.
> 
> >>> Then, SELinux
> >>> checks if 'kernel_t' can access the inode with the security context of 'I'.
> >> Why doesn't eCryptfs provide the credentials of 'I'? In the kernel you
> >> can do what you will.
> > No, eCryptfs provides (in the following patch) the 'initial' credentials which
> > are obtained through the function prepare_kernel_cred() which give root
> > privileges. These credentials are used in the hook security_dentry_open()
> > to verify if eCryptfs is allowed to access the inode 'I' in the underlying
> > filesystem.
> 
> But you shouldn't care if eCryptfs can access the file. You should
> only care if the user process can access the file. You're kernel code,
> you can do what you will.
> 
> >>> If so,
> >>> eCryptfs obtains a file descriptor which, in this patch set, is labeled using the
> >>> same credentials it provided at open time and binds it to the upper inode.
> >>>
> >>> Suppose for a moment that A is working on the eCryptfs inode 'I' and the process
> >>> B requests the same inode. ECryptfs uses the already opened file descriptor and
> >>> B will be granted to open the requested inode if:
> >>>
> >>> - B has the 'open' permission on the upper inode 'I';
> >>>
> >>>
> >>> and can perform read/write operations if:
> >>>
> >>> - B has the 'read' and 'write' permissions on the upper inode 'I';
> >>> - B is allowed to use the file descriptor opened by eCryptfs ('kernel_t').
> >>> - B has the 'read' and 'write' permissions on the lower inode I;
> >>>
> >>>
> >>> What i miss to say in my previous email is that even if eCryptfs is granted
> >>> to access inodes in the lower filesystem with full privileges, user processes
> >>> still need the permission to deal with the lower inode, but the check on the
> >>> upper inode is sufficient because the security context is the same.
> >> Right, but what I don't understand is why you can't use existing
> >> mechanisms to achieve this? NFS manages (mostly).
> >>
> > Please, can you explain better this thought?
> 
> NFS provides a network "view" of an ext4 (or any type for that matter)
> filesystem. NFS does not support extended attributes, but there has been
> ongoing work on that. It seems that if NFS does not require the kind
> of changes you are requesting you shouldn't either.
> 

I'm not familiar with NFS, so i cannot answer about this scenario.
I'm adding in CC also the NFS mantainers and the mailing list so
that they can express their point of view. The whole thread is
available at:

https://lkml.org/lkml/2011/4/27/201

Roberto Sassu


> >>>> Excuse my ignorance for a moment. Is eCryptfs a user mode filesystem,
> >>>> or in the kernel properly? The behavior makes it sound like the former
> >>>> while the interfaces you're requesting make it seem like the latter.
> >> I'll repeat the question because it matters.
> > As already reported by Guido Trentalancia, eCryptfs is a kernel mode
> > filesystem, which accepts data from the VFS layer, encrypts or decrypts
> > them and store the result in the underlying filesystem, always passing from
> > the VFS interface.
> >
> > Roberto Sassu
> >
> >
> >>
> > --
> > This message was distributed to subscribers of the selinux mailing list.
> > If you no longer wish to subscribe, send mail to majordomo@tycho.nsa.gov with
> > the words "unsubscribe selinux" without quotes as the message.
> >
> >
> 
> 
