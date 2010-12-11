Return-Path: <nfsv4-bounces@ietf.org>
From: "P.B.Shelley" <shelleypt@gmail.com>
Date: Sun, 12 Dec 2010 00:39:45 +0800
Message-ID: <AANLkTimDjL8GmU64RJfrtJxdhemziYKrjpSTHoemzR0k@mail.gmail.com>
To: linuxnfs <linux-nfs@vger.kernel.org>, nfsv4 <nfsv4@ietf.org>
Subject: [nfsv4] Question about NFS41 server attributes changes
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a questions about NFS41 server attributes. The protocol defines
clearly in section 5.6 which attributes are modifiable by client and
which are not. But it is not clear on which attributes are modifiable
by server or not. Take the fs_layout_type and layout_blksize attribute
as an example. Can server change them at any time? What should client
do if server changes some attributes on its own?

-- 
Thanks,
Shelley
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
